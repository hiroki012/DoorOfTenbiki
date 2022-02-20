[return cond="typeof(global.krclick_obj) != 'undefined'"]

; コンフィグ・セーブ・ロード画面例
;
; 本例の画面構成は、「右クリックでの設定画面を TJS2 で実現するサンプル
; 2002/6/14 版」をモノスゴ参考にさせて頂きました。御礼申し上げます。
;
; Config.tjs の設定を以下のようにする必要あり
;   freeSaveDataMode = false;
;   saveThumbnail    = true;
;   numBookMarks     = 48;
;   thumbnailWidth   = 128/640*scWidth;
; Krclick.ks : このファイル。右クリックルーチンのメインルーチン
; Krclick_Data_Config.ks: コンフィグ画面を構成するレイヤの配置データ
; Krclick_Data_SaveLoad.ks: セーブ画面・ロード画面を構成するレイヤの配置データ
;
; 2016/03/13	0.14	・セーブ・ロード画面でページ選択すると操作できなく
;			　なっていたのを修正
; 2015/12/14	0.13	・[終了]→ダイアログで[No]を選ぶと画面表示が乱れる
;			　場合があった問題を修正
; 2014/03/30	0.12	・KAGEXでも動くよう、askYesNo()の使い方を場合分け
; 2013/12/04	0.11	・saveBookMarkWithAsk()をちょっとだけ最適化
;			・コメント内の古いloadBookMarkWithAsk()実装を削除
; 2013/12/02	0.1	初期リリース


; 前提プラグイン読み込み
[call storage="KLayers.ks"]

[iscript]
// 画面サイズが変わっても相対位置・大きさを変更しないために、640x480を基本に、
// 実際の画面サイズ(scWidth/scHeight)に合わせて座標を返す関数。
// Krclick_Data_Confit.ksとKrclick_Data_SaveLoad.ksの中から利用する。
function rposx(x)
{
	return x*kag.scWidth/640;
}
function rposy(y)
{
	return y*kag.scHeight/480;
}
[endscript]



; コンフィグ画面の定義辞書配列読み込み
[call storage="Krclick_Data_Config.ks"]

; セーブ・ロード画面の定義辞書配列読み込み
[call storage="Krclick_Data_SaveLoad.ks"]

[iscript]

if (!kag.saveThumbnail)
	System.inform('system/Config.tjs で saveThumbnail を '+
			'true にしてください。');


// ここでデフォルトフォントを定義してもいいが、コレやるとKLayersを使う
// 全てのレイヤのデフォルトが変更されるので、下の sf.rcMenu.LayerDefaultの
// 中を変更した方がよい。
// .KFont_default.face   = 'ＭＳ Ｐゴシック',
// .KFont_default.height = 10;


// 初期化関数。
// キャラクタデータは必ずしも sf にセーブされず、f にセーブされることがあり、
// その場合にタイトルに戻って[clearvar]された後に再設定できるように。
function init_rcMenu()
{
	// グローバルシステム変数のデフォルト値設定
	if (sf.rcMenu === void) {
		sf.rcMenu = %[
			curPage		: 0,	// 現在のload/save表示ページ
			BgmVolume	: 100,	// BGMボリューム
			BgmMute		: false,// BGMミュートcheckbox
			SeVolume	: 100,	// SEボリューム
			SeMute		: false,// SEミュートcheckbox
			bookMarkComments: [],	// コメント(現在未使用)
			bookMarkMessages: [],	// 画面に表示されてたメッセージ
			LayerDefault    : %[
				// 各種レイヤのデフォルト値
				// ↓この辞書はなくてもよい
				absolute   : 20000000+1,
//				color      : 0xff004080,
//				entercolor : 0xff70b0f0,
//				clickcolor : 0xff90d0ff,
				kfont : %[
					face   : 'ＭＳ Ｐゴシック',
					height : rposx(10)
				],
				enterfont : %[
					height : rposx(14)
				],
				clickfont : %[
					height : rposx(14)
				],
				buttonopts : %[	 // RadioButtonのデフォルト値
//					color      : 0xff004080,
//					entercolor : 0xff70b0f0,
//					clickcolor : 0xff90d0ff,
					kfont : %[
						face   : 'ＭＳ Ｐゴシック',
						height : rposx(10)
					],
					enterfont : %[
						height : rposx(14)
					],
					clickfont : %[
						height : rposx(14)
					]
				]
			]
		];
	}

	// 未読の文字表示に「とても遅い(V)」を追加(速度段階(=5)の為
	if (typeof(kag.chVerySlowMenuItem) == 'undefined') {
		kag.chVerySlowMenuItem = new KAGMenuItem(kag,
					"とても遅い(&V)",
					1,
					kag.onChSpeedMenuItemClick, false);
		kag.chSpeeds.nowait = 0;	// nowaitを追加しておく
		// NormalとSlowの比率からVerySlowを計算する
		 kag.chSpeeds.veryslow = int((kag.chSlowMenuItem.speed*kag.chSlowMenuItem.speed)/kag.chNormalMenuItem.speed);
		kag.chVerySlowMenuItem.speed = kag.chSpeeds.veryslow;
		kag.chSpeedMenu.insert(kag.chVerySlowMenuItem, 4);
	}

	// 既読の文字表示から「変えない(&M)」を削除(オブジェクトは残す)
	if (kag.ch2ndSpeedMenu.children.find(kag.ch2ndNoChangeMenuItem) >= 0)
		kag.ch2ndSpeedMenu.remove(kag.ch2ndNoChangeMenuItem);
	// 既読の文字表示に「遅い(V)」を追加(速度段階(=5)の為
	if (typeof(kag.ch2ndSlowMenuItem) == 'undefined') {
		kag.ch2ndSlowMenuItem = new KAGMenuItem(kag,
					"遅い(&S)",
					1,
					kag.onCh2ndSpeedMenuItemClick, false);
		// FastとNormalの比率からSlowを計算する
		kag.ch2ndSlowMenuItem.speed = kag.chSpeeds.slow;
		kag.ch2ndSpeedMenu.insert(kag.ch2ndSlowMenuItem, 3);
	}
	// 既読の文字表示に「とても遅い(V)」を追加(速度段階(=5)の為
	if (typeof(kag.ch2ndVerySlowMenuItem) == 'undefined') {
		kag.ch2ndVerySlowMenuItem = new KAGMenuItem(kag,
					"とても遅い(&V)",
					1,
					kag.onCh2ndSpeedMenuItemClick, false);
		// FastとNormalの比率からSlowを計算する
		kag.ch2ndVerySlowMenuItem.speed = kag.chSpeeds.veryslow;
		kag.ch2ndSpeedMenu.insert(kag.ch2ndVerySlowMenuItem, 4);
	}

	// 各種ボリュームを初期化
	setBgmVolume  (getBgmVolume());	// 音声ボリュームを設定
	setSeVolume   (getSeVolume());	// SEボリュームを設定

	// 各種メッセージスピードを初期化
	setMessageSpeed1(getMessageSpeed1());	// 未読メッセージ
	setMessageSpeed2(getMessageSpeed2());	// 既読メッセージ
	setMessageSpeedAuto(getMessageSpeedAuto()); // オートメッセージ

	// tf.loadbookmarknum は定義してはならない。以下でloadの時に使うため。
	delete tf.loadbookmarknum;
	// tf.krclickmode は定義してはならない。以下でモード指定に使うため。
	delete tf.krclickmode;
}



// 画面作成関数 ###########################################################

// dicに無いパラメータをdefで上書き
function marge_dic_default(dic, def)
{
	if (def === void)
		return dic;
	var defkeys = keys(def);
	for (var i = defkeys.count-1; i >= 0; i--) {
		var key = defkeys[i];
		var type = typeof(dic[key]);
		if (type == 'undefined')
			dic[key] = def[key];
		else if (type == 'Object') // dicのはず
			marge_dic_default(dic[key], def[key]);
	}
	return dic;
}

// sf.rcMenu.LayerDefault をデフォルト値としてレイヤを作成する
function createLayersWithDefault(itemary, parent, fromtitle='false')
{
	if (sf.rcMenu.LayerDefault !== void)
		for (var i = itemary.count-1; i >= 0; i--){
			
			//タイトルからくる場合、ウィンドウを消すモードの閉じるボタンの配置をスキップ
			if(fromtitle && i == itemary.count-2){
				continue;
			}

			//タイトルから以外の場合、従来通りに動かす
			if(!fromtitle && i == itemary.count-1){
				continue;
			}

			marge_dic_default(itemary[i], sf.rcMenu.LayerDefault);
		}
	return createLayers(itemary, parent);
}


// ロード・セーブ画面の一アイテムを作成する
function make_loadsave_item(itemary, num, parent)
{
/* 設定可能項目
		name	: "thumbnail"		// サムネイル画像
		name	: "label"		// ラベル名
		name	: "protectcheckbox"	// 記録保護チェックボックス
		name	: "item#"		// アイテムNo.
		name	: "date"		// 日付
//今はなし	name	: "comment"		// コメント

[iscript]中では頭に*を書かないこと！*/
	var ret = createLayersWithDefault(itemary, parent);

	// これらはユニークに唯一存在する必要がある
	var thumb  = findLayer('thumbnail',       parent, false);
	var label  = findLayer('label',           parent, false);
	var pcb    = findLayer('protectcheckbox', parent, false);
	var itemno = findLayer('item#',           parent, false);
	var date   = findLayer('date',            parent, false);
	var cmnt   = findLayer('comment',         parent, false);
	var msg    = findLayer('message',         parent, false);

	var tnstr      = kag.getBookMarkFileNameAtNum(num);
	var labelstr   = "記録なし";
	var pcbchecked = false;
	var datestr    = "日付：----/--/-- --:--:--:--";
	var cmntstr    = "";
	var msgstr     = "";

	if (Storages.isExistentStorage(tnstr) && kag.bookMarkDates[num] != ""){
		datestr    = "日付："+kag.bookMarkDates[num];
		labelstr   = kag.bookMarkNames[num];
		pcbchecked = kag.bookMarkProtectedStates[num];
		if (sf.rcMenu.bookMarkComments !== void)
			cmntstr = sf.rcMenu.bookMarkComments[num];
		if (sf.rcMenu.bookMarkMessages !== void)
			msgstr  = sf.rcMenu.bookMarkMessages[num];
		// サムネイル設定
		thumb.setOptions(%[graphic:tnstr]) if (thumb !== void);
	} else {
		// サムネイル画像が手動で削除された時にも対応
		if (kag.bookMarkDates[num] != "") {
			kag.bookMarkNames[num] = ""; // 記録名
			kag.bookMarkDates[num] = ""; // 保存年月日
			// メッセージレイヤに表示されてたメッセージ
			if (sf.rcMenu.bookMarkComments !== void)
				sf.rcMenu.bookMarkComments[num] = "";
			kag.setBookMarkMenuCaptions();
		}
		// サムネイル設定
		tnstr = "記録無し";
		if (thumb !== void)
			thumb.setOptions(%[graphic:"", text:"記録なし"]);
	}

	// 保存日時設定
	date  .setOptions(%[text:datestr   ]) if (date   !== void);
	// 栞名称設定
	label .setOptions(%[text:labelstr  ]) if (label  !== void);
	// 記録保護チェックボックス設定
	if (pcb !== void)
		pcb   .setOptions(%[checked:pcbchecked, 
			    stateval:"kag.bookMarkProtectedStates["+num+"]"]);
	// ロード・セーブ番号設定
	itemno.setOptions(%[text:num+1     ]) if (itemno !== void);
	// コメント設定
	cmnt  .setOptions(%[text:cmntstr   ]) if (cmnt   !== void);
	// 表示メッセージ設定
	msg   .setOptions(%[text:msgstr    ]) if (msg    !== void);

	return ret;
}


// ロード設定 ################################################################

// ロード画面のアイテム群を作成する
function make_load_items(pagenum=sf.rcMenu.curPage, page='fore')
{
	var parent = kag[page].base;
	var ret = [], lary = [], l;
	sf.rcMenu.curPage = pagenum;
	for (var i = 0; (l = findLayer('load_item'+i, parent)) !== void; i++) {
		for (var j = l.children.count-1; j >= 0; j--) {
			// 子供を全部削除
			var cl = l.children.pop();
			if (page == 'fore')
				.krclick_obj.forelayers.remove(cl);
			else
				.krclick_obj.backlayers.remove(cl);
			invalidate cl;		// 子供を全部削除
		}
		lary.add(l);
	}
	var itemno = lary.count*pagenum;
	for (var i = 0; i < lary.count; i++, itemno++) {
		// "load_item[0-9]+" を親に、load_itemを追加
		var itemary = [];		// ここで作ることに注意
		itemary.assignStruct(load_item);
		for (var j = itemary.count-1; j >= 0; j--)
			itemary[j].parent = 'load_item'+i;
		add_ary(ret, make_loadsave_item(itemary, itemno, lary[i]));
	}
	return ret;	// 配列を全部返す。
}


// ロード画面の表示ページ切り替えボタンが押された
// 表→裏コピー　→　裏画面に次画面作成　→　トランジションして表示
function change_load_page(index)
{
	if (sf.rcMenu.curPage == index)
		return;
	kag.tagHandlers.backlay(%[]);
	// .krclick_obj.show() でやると、以下のように無限ループするので
	// onCheck()→show()→createLayers()→onCheck()→...
	// ※今試したら無限ループしなくなってたが、効率化のためこのままに。
	add_ary(.krclick_obj.backlayers, make_load_items(index, 'back'));
	.krclick_obj.moveto_noshow('back');
}


// ロード画面を作成する
function make_load_screen(pagenum=sf.rcMenu.curPage, page='fore')
{
	var parent = kag[page].base;
	// ボタン情報配列 "load_screen"、"load_item" でロード画面を作成する
	init_load_screen_values();
	var ret = createLayersWithDefault(load_screen, parent);
	add_ary(ret, make_load_items(pagenum, page));
	findLayer('page_select', parent).makeCheck(pagenum);	// ボタンを押す
	return ret;	// 配列を全部返す。トップだけ返すと他が invalidate
			// される模様。なんでやのん。
}


// 栞をロードする
function loadBookMarkWithAsk(num)
{
	// kag.loadBookMarkWithAsk(num)は、ここでは実行しない。実行すると
	// その瞬間に色々invalidateされてエラーになるため。一度movetoで
	// 終了させ、その時に tf.loadbookmarknum が設定されていたらロードする
	// ようにする
	// ロード時、画面は、.krclick_obj.onRestore()中でクリアされる
	
	// bookMarkDates が空文字の場合は栞は存在しない
	if (num >= kag.numBookMarks || kag.bookMarkDates[num] == "")
		return false;

	var prompt = .load_message.sprintf(kag.bookMarkNames[num]);

	if (typeof(.ImageDialogLayerPlugin_obj) != 'undefined' &&
	    .ImageDialogLayerPlugin_obj.options.enabled) {
		// YesNoDialogLayerを利用中の場合。↓は必ずfalseで戻る
		.ImageDialogLayerPlugin_obj.askYesNoLayer(prompt, loadBookMarkWithAsk_next, num);
	} else {
		// YesNoDialogLayerを利用中でない場合→デフォルトYesNoDialog
		if (kagVersion.substr(0,2) == "EX") {
			// KAGEXの時
			askYesNo(prompt, , loadBookMarkWithAsk_next, , num);
		} else {
			// 普通のKAGの時
			if (askYesNo(prompt))
				loadBookMarkWithAsk_next(num);
		}
	}
}

// ロード時、[Yes]が選択された場合に実行される
function loadBookMarkWithAsk_next(num)
{
	// 読み込みますか → Yes なら。
	kag.loadBookMark(num);
	tf.loadbookmarknum = num;
	// メニューを終了し、データをロードする
	.krclick_obj.moveto('back', .krclick_obj.CLEAR);
}


// セーブ設定 ################################################################

// セーブ画面のアイテム群を作成する
function make_save_items(pagenum=sf.rcMenu.curPage, page='fore')
{
	var parent = kag[page].base;
	var ret = [], lary = [], l;
	sf.rcMenu.curPage = pagenum;
	for (var i = 0; (l = findLayer('save_item'+i, parent)) !== void; i++) {
		for (var j = l.children.count-1; j >= 0; j--) {
			// 子供を全部削除
			var cl = l.children.pop();
			if (page == 'fore')
				.krclick_obj.forelayers.remove(cl);
			else
				.krclick_obj.backlayers.remove(cl);
			invalidate cl;		// 子供を全部削除
		}
		lary.add(l);
	}
	var itemno = lary.count*pagenum;
	for (var i = 0; i < lary.count; i++, itemno++) {
		// "save_item[0-9]+" を親に、save_itemを追加
		var itemary = [];		// ここで作ることに注意
		itemary.assignStruct(save_item);
		for (var j = itemary.count-1; j >= 0; j--)
			itemary[j].parent = 'save_item'+i;
		add_ary(ret, make_loadsave_item(itemary, itemno, lary[i]));
		
	}
	return ret;	// 配列を全部返す。
}


// セーブ画面の表示ページ切り替えボタンが押された
// 表→裏コピー　→　裏画面に次画面作成　→　トランジションして表示
function change_save_page(index)
{
	if (sf.rcMenu.curPage == index)
		return;
	kag.tagHandlers.backlay(%[]);
	// .krclick_obj.show() でやると、以下のように無限ループするので
	// onCheck()→show()→createLayers()→onCheck()→...
	// ※今試したら無限ループしなくなってたが、効率化のためこのままに。
	add_ary(.krclick_obj.backlayers, make_save_items(index, 'back'));
	.krclick_obj.moveto_noshow('back');
}


// セーブ画面を作成する
function make_save_screen(pagenum=sf.rcMenu.curPage, page='back')
{
	var parent = kag[page].base;
	// ボタン情報配列 "save_screen"、"save_item" でセーブ画面を作成する
	init_save_screen_values();
	var ret = createLayersWithDefault(save_screen, parent);
	add_ary(ret, make_save_items(pagenum, page));
	findLayer('page_select', parent).makeCheck(pagenum);	// ボタンを押す
	return ret;	// 配列を全部返す。トップだけ返すと他が invalidate
			// される模様。なんでやのん。
}


// 栞をセーブする
// セーブ後に画面を更新するために、loadBookMarkWithAsk()と随分違う
function saveBookMarkWithAsk(num)
{
	// セーブ時、画面を.krclick_obj.onStore()中で更新しようと思ってたが、
	// onStore()は「ラベル通過時」に動くのであきらめた…

	if (kag.readOnlyMode || num >= kag.numBookMarks ||
	    kag.bookMarkProtectedStates[num])
		return false;

	if (kag.bookMarkDates[num] == "") { // 新規なら何も聞かずにセーブ
		saveBookMarkWithAsk_next(num);
		return;
	}

	var prompt = .save_message.sprintf(kag.pcflags.currentPageName);
	if (typeof(.ImageDialogLayerPlugin_obj) != 'undefined' &&
	    .ImageDialogLayerPlugin_obj.options.enabled) {
		// YesNoDialogLayerを利用中でない場合→デフォルトYesNoDialog
		.ImageDialogLayerPlugin_obj.askYesNoLayer(prompt, saveBookMarkWithAsk_next, num);
	} else {
		// YesNoDialogLayerを利用中でない場合→デフォルト動作
		if (kagVersion.substr(0,2) == "EX") {
			// KAGEXの時
			askYesNo(prompt, , saveBookMarkWithAsk_next, , num);
		} else {
			// 普通のKAGの時
			if (askYesNo(prompt))
				saveBookMarkWithAsk_next(num);
		}
	}
}

//セーブ時、[Yes]が選択された場合に実行される
function saveBookMarkWithAsk_next(num)
{
	// 書き込みますか → Yes なら。
	kag.saveBookMark(num);
	if(sf.rcMenu.bookMarkComments !== void)
		sf.rcMenu.bookMarkComments[num] = ""; // コメントクリア
	if(sf.rcMenu.bookMarkMessages !== void)
		sf.rcMenu.bookMarkMessages[num] = f.messagestore;
	if (.krclick_obj.mode == .krclick_obj.SAVE)
		make_save_items();	// メニューセーブでなければボタンを更新
}


// コンフィグ設定 ###########################################################

// コンフィグ画面を作成する
function make_config_screen(page='fore', fromtitle='false')
{
	init_config_screen_values();
	return createLayersWithDefault(config_screen, kag[page].base, fromtitle);
}


// BGMボリューム(0～100)を得る
function getBgmVolume()
{
	var vol = sf.rcMenu.BgmVolume;
	if (sf.rcMenu.BgmMute)
		vol = 0;
	return int(vol);
}
// BGMボリュームを変更する(hval しか使わない、hval = 0～100)
function setBgmVolume(hval, vval, dragging)
{
	var vol = hval;
	if (!sf.rcMenu.BgmMute)
		sf.rcMenu.BgmVolume = vol;
	else
		vol = 0;
	kag.bgm.setOptions(%[gvolume:vol]);

	var l;
	if ((l = findLayer("bgmvval")) !== void)
		l.setOptions(%[text:string(vol)]);
	if ((l = findLayer("bgmslider")) !== void)
		l.setOptions(%[hval:vol]);
//	kag.saveSystemVariables();	// あると100msくらいかかるので削除
}


// SEボリューム(0～100)を得る
function getSeVolume()
{
	var vol = sf.rcMenu.SeVolume;
	if (sf.rcMenu.SeMute)
		vol = 0;
	return int(vol);
}
// SEボリュームを変更する(hval しか使わない、hval = 0～100)
function setSeVolume(hval, vval, dragging)
{
	var vol = hval;
	if (!sf.rcMenu.SeMute)
		sf.rcMenu.SeVolume = vol;
	else
		vol = 0;

	for (var i = kag.numSEBuffers-1; i >= 0; i--)
		kag.se[i].setOptions(%[gvolume:vol]);

	var l;
	if ((l = findLayer("sevval")) !== void)
		l.setOptions(%[text:string(vol)]);
	if ((l = findLayer("seslider")) !== void)
		l.setOptions(%[hval:vol]);
//	kag.saveSystemVariables();	// あると100msくらいかかるので削除
}


// 未読メッセージ表示速度(ボタンインデックス)を得る
function getMessageSpeed1(buttonnum)
{
	var uchs = kag.userChSpeed, chs = kag.chSpeeds;

	// ホントはbuttonnumが使えるといいんだが、ここでは使えないので泥臭く
	return  (uchs <= chs.nowait) ? 4 :
		(uchs <= chs.fast  ) ? 3 :
		(uchs <= chs.normal) ? 2 :
		(uchs <= chs.slow  ) ? 1 : 0;
	// 4 = buttonum-1
	// buttonnum ; // オートメッセージボタン数
}


// 未読メッセージ表示速度を設定する(index=hval しか使わない)
function setMessageSpeed1(hval, vval, dragging)
{
	var clickfunc = [
		"kag.chVerySlowMenuItem.click()",
		"kag.chSlowMenuItem.click()",
		"kag.chNormalMenuItem.click()",
		"kag.chFastMenuItem.click()",
		"kag.chNoWaitMenuItem.click()"
	];
	Scripts.eval(clickfunc[hval]);
}


// 既読メッセージ表示速度(ボタンインデックス)を得る
function getMessageSpeed2(buttonnum)
{
	var uch2s = kag.userCh2ndSpeed, chs = kag.chSpeeds;

	// ホントはbuttonnumが使えるといいんだが、ここでは使えないので泥臭く
	return  (uch2s <= chs.nowait) ? 4 :
		(uch2s <= chs.fast  ) ? 3 :
		(uch2s <= chs.normal) ? 2 : 
		(uch2s <= chs.slow  ) ? 1 : 0;
	// 4 = buttonum-1
	// buttonnum ; // オートメッセージボタン数
}

// 既読メッセージ表示速度を設定する
function setMessageSpeed2(hval, vval, dragging)
{

	var clickfunc = [
		"kag.ch2ndVerySlowMenuItem.click()",
		"kag.ch2ndSlowMenuItem.click()",
		"kag.ch2ndNormalMenuItem.click()",
		"kag.ch2ndFastMenuItem.click()",
		"kag.ch2ndNoWaitMenuItem.click()"
	];
	Scripts.eval(clickfunc[hval]);
}


// オートメッセージ表示速度(ボタンインデックス)を得る
function getMessageSpeedAuto(buttonnum)
{
	var ampw = kag.autoModePageWait, ampws = kag.autoModePageWaits;

	// ホントはbuttonnumが使えるといいんだが、ここでは使えないので泥臭く
	return  (ampw <= ampws.fast  ) ? 4 :
		(ampw <= ampws.faster) ? 3 :
		(ampw <= ampws.medium) ? 2 : 
		(ampw <= ampws.slower) ? 1 : 0;
	// 4 = buttonum-1
	// buttonnum ; // オートメッセージボタン数
}

// オートメッセージ表示速度を設定する
function setMessageSpeedAuto(hval, vval, dragging)
{
	var clickfunc = [
		"kag.autoModeSlowMenuItem.click()",
		"kag.autoModeSlowerMenuItem.click()",
		"kag.autoModeMediumMenuItem.click()",
		"kag.autoModeFasterMenuItem.click()",
		"kag.autoModeFastMenuItem.click()"
	];
	Scripts.eval(clickfunc[hval]);
}



// 右クリックルーチンプラグイン本体 ##########################################
class RClickPlugin extends KAGPlugin
{
	var	window;
	var	forelayers = [];
	var	backlayers = [];
	var 	mode;	// 現在の画面モード
	var     CLEAR=-1, CONFIG=0, LOAD=1, SAVE=2, CONFIG_FROM_TITLE=3;
		// -1:表示消去, 0:コンフィグ 1:ロード 2:セーブ

	// コンストラクタ
	function RClickPlugin(window)
	{
		super.KAGPlugin();
		this.window = window;
		// デフォルトで、画面と同じサイズのものをひとつ定義しておく。
		clear('both');
	}

	// デストラクタ
	function finalize()
	{
		invalidate_layers(forelayers);
		invalidate_layers(backlayers);
		super.finalize();
	}

	// forelayers/backlayers にオプションを設定する
	function setOptions(page='fore', elm)
	{
		if (page == 'fore' || page == 'both')
			for (var i = forelayers.count-1; i >= 0; i--)
				forelayers.setOptions(elm);
		if (page == 'back' || page == 'both')
			for (var i = backlayers.count-1; i >= 0; i--)
				backlayers.setOptions(elm);
	}

	// レイヤーを削除する場合にchildrenを先に削除する
//	function invalidate_layers_sub(layer)
//	{
//		for (var i = layer.children.count-1; i >= 0; i--)
//			invalidate_layers_sub(layer.children[i]);
//		invalidate layer;
//	}

	// レイヤーを削除する
	function invalidate_layers(layers)
	{
		for (var i = layers.count-1; i >= 0; i--)
			invalidate layers.pop();
	}

	// 指定されたモード(CLEAR:クリア, CONFIG:menu, LOAD:load, SAVE:save, CONFIG_FROM_TITLE:タイトル画面からのmenu)
	// 画面を表示する
	function show(page='fore', mode=this.mode, pagenum=sf.rcMenu.curPage)
	{
		clear(page);
		this.mode = mode;
		if (mode == LOAD) {
			// ロード画面作成
			if (page == 'fore' || page == 'both') {
				forelayers = make_load_screen(pagenum, 'fore');
				configureFocus(forelayers);
			}
			if (page == 'back' || page == 'both') {
				backlayers = make_load_screen(pagenum, 'back');
				configureFocus(backlayers);
			}
		} else if (mode == SAVE) {
			// セーブ画面作成
			if (page == 'fore' || page == 'both') {
				forelayers = make_save_screen(pagenum, 'fore');
				configureFocus(forelayers);
			}
			if (page == 'back' || page == 'both') {
				backlayers = make_save_screen(pagenum, 'back');
				configureFocus(backlayers);
			}
		} else if (mode == CONFIG) {
			// メニュー画面作成
			if (page == 'fore' || page == 'both') {
				forelayers = make_config_screen('fore');
				configureFocus(forelayers);
			}
			if (page == 'back' || page == 'both') {
				backlayers = make_config_screen('back');
				configureFocus(backlayers);
			}
		} else if (mode == CONFIG_FROM_TITLE) {
			// メニュー画面作成
			if (page == 'fore' || page == 'both') {
				forelayers = make_config_screen('fore', true);
				configureFocus(forelayers);
			}
			if (page == 'back' || page == 'both') {
				backlayers = make_config_screen('back', true);
				configureFocus(backlayers);
			}
		}
		// mode == CLEAR の場合は上で init しているので何もしない
	}

	// 画面クリア
	function clear(page='fore')
	{
		mode = CLEAR;
		if (page == 'fore' || page == 'both')
			invalidate_layers(forelayers);
		if (page == 'back' || page == 'both')
			invalidate_layers(backlayers);
	}

	// 指定モードの、画面の enabled/disabled を切り替える
	// 実際にはxxx_backgroundだけを変更。これで子もアクセス不能になる
	function enabled(enabled=true, page='fore', mode=this.mode)
	{
		if (mode == CLEAR)
			return;
		var l, laynam = 'config_background';
		if (mode == LOAD)
			laynam = 'load_background';
		else if (mode == SAVE)
			laynam = 'save_background';
		if (page == 'fore' || page == 'both') {
			l = findLayer(laynam, kag.fore.base, false);
			l.enabled = +enabled if (l !== void);
		}
		if (page == 'back' || page == 'both') {
			l = findLayer(laynam, kag.back.base, false);
			l.enabled = +enabled if(l !== void);
		}
	}

	// 画面を変更して終わる
	function moveto(page='fore', mode=this.mode, pagenum=sf.rcMenu.curPage)
	{
		// 背景を描いてから終了トリガを引く
		show(page, mode, pagenum);
		moveto_noshow(page);
	}

	// 画面を変更して終わる
	function moveto_noshow(page='fore')
	{
		// 背景は最初 enabled=false にしておく
		enabled(false, 'both');
		window.trigger('krclick_end');

		// 画面更新の必要があるときは確実に更新できるように追加。
		delete tf.krclickmode;
		// 右クリックルーチン中でkag.closeBysScript()で[No]を選択した
		// 場合に、別のトリガを待っていた[wait]が終了してしまうのを防ぐ
		// ため、末尾のKAGスクリプトに
		// [jump target=*krclick_loop2 cond="tf.krclickmode == .krclick_obj.mode"]
		// を追加した。ら、今度は同じ画面を表示しつつmoveto()や
		// moveto_noshow()で終わった場合(ロード画面のページ選択など)に
		// ページが切り替わらなくなってしまった。
		// ↑はこれを修正するために追加。
	}

	// ロード時
	function onRestore(f, clear_val, elm)
	{
		clear('both');	// 表示されてるはずのロード画面をクリア
	}

	// レイヤの表←→裏の情報のコピー
	function onCopyLayer(toback)
	{
		if (toback) {	// 表→裏
			invalidate_layers(backlayers);
			for (var i = 0; i < forelayers.count; i++) {
				var fl = forelayers[i], classid, bp, layer;
				classid = global[fl.classid];
				bp = findLayer(fl.parent.name, kag.back.base);
				bp = kag.back.base if (bp === void);
				layer = new classid(fl.window, bp, fl.name);
				layer.assign(fl);
				backlayers.add(layer);
			}
		} else {	// 裏→表
			invalidate_layers(forelayers);
			for (var i = 0; i < backlayers.count; i++) {
				var bl = backlayers[i], classid, fp, layer;
				classid = global[bl.classid];
				fp = findLayer(bl.parent.name, kag.fore.base);
				fp = kag.fore.base if (fp === void);
				layer = new classid(bl.window, fp, bl.name);
				layer.assign(bl);
				forelayers.add(layer);
			}
			configureFocus(forelayers);
		}
	}

	// 裏と表の管理情報を交換
	function onExchangeForeBack()
	{
		var tmp = backlayers;
		backlayers = forelayers;
		forelayers = tmp;
		configureFocus(forelayers);
	}
}

kag.addPlugin(.krclick_obj = new RClickPlugin(kag));


[endscript]

[macro name=rcmenu_init]
[eval exp="init_rcMenu()"]
[endmacro]

; 一度初期化しておく
[rcmenu_init]

[return]


; ここから KAG プログラム #################################################

; コンフィグ画面表示
*krclick_config
[eval exp="tf.krclickmode = .krclick_obj.CONFIG"]
[jump target=*krclick_main]

*krclick_config_from_title
[eval exp="tf.krclickmode = .krclick_obj.CONFIG_FROM_TITLE"]
[jump target=*krclick_main]

; ロード画面表示
*krclick_load
[return cond="!kag.canRestore()"]
[eval exp="tf.krclickmode = .krclick_obj.LOAD"]
[jump target=*krclick_main]


; セーブ画面表示
*krclick_save
[return cond="!kag.canStore()"]
[eval exp="tf.krclickmode = .krclick_obj.SAVE"]
[jump target=*krclick_main]


; 右クリックメインルーチン(ここにくるまでにtf.krclickmodeが設定されていること)
*krclick_main
[locklink]
[locksnapshot]
; これは load で使うので削除しておく
[eval exp="delete tf.loadbookmarknum"]
[stoptrans]
[backlay]
[eval exp=".krclick_obj.show('back', tf.krclickmode)"]

*krclick_loop
; 最初は enabled=false にしておく
[eval exp=".krclick_obj.enabled(false, 'both')"]
[stoptrans]
[trans method=crossfade time=200]
[wt canskip=false]
; 表示し終わったら enabled=true
[eval exp=".krclick_obj.enabled(true, 'both')"]

; "krclick_end" トリガが引かれるまで待機
*krclick_loop2
[waittrig name="krclick_end"]
; 右クリックルーチン中でkag.closeByScript()を呼んで[No]を選択した場合、
; (本来このKAGの処理に戻ってきて欲しくないのだが、実際には戻ってきて、)
; [waittirg name="krclick_end"]から処理が進んでしまう。そのため、
; [終了]ボタンを押して[No]でConfig画面に戻ると、画面表示が裏画面に
; 切り替わってしまうという問題があった。
; これは、kag.closeByScript()中ではconductor.wait()を実行していて 'not_closed'
; トリガを待つ処理があり、conductorは複数のtriggerを待つことはできずあとから
; 指定したトリガで上書きされるため。だから、'krclick_end' を待ってたのに
; 'not_closed' で waittrig が終了してしまう。
; これを防ぐことはできないため、書き換えの必要がなければ、ループさせる。
; 書き換えが必要なときは、moveto_noshow()の中でdelete tf.krclickmodeすることで
; 下の[jump]をスキップするようにした。つまり、条件は以下。
; 　　書き換え必要： tf.krclickmode = void(未定義)
; 　　書き換え不要(YesNoDialogでNoが選択されるなど)： tf.krclickmode = 現在のモード
; .krclick_obj.REDRAWを新しく定義しなかったのは、REDRAWを通知すべきはこのKAG
; スクリプトのみであり、TJSスクリプト側ではないため。
[jump target=*krclick_loop2 cond="tf.krclickmode == .krclick_obj.mode"]
[eval exp="tf.krclickmode = .krclick_obj.mode"]

; 念のため sf.* をセーブする。本当はここじゃないほうがいいんだけど、この
; 関数は実行に数十msくらいかかって遅いので。
[eval exp="kag.saveSystemVariables()"]

; 現在表示中の画面をロックして、ボタンが押せないようにしておく
[eval exp=".krclick_obj.enabled(false, 'both')"]

; この時点で裏画面に何かが描かれているか、終了時は何も描かれていない
; で、mode が CLEAR なら終了、そうでなければ描画ループへ
[jump target=*krclick_loop     cond=".krclick_obj.mode != .krclick_obj.CLEAR"]
[jump target=*krclick_dataload cond="tf.loadbookmarknum !== void"]

[stoptrans]
;[sysbutton_erase page=fore]
;[sysbutton_erase page=back]
[trans method=crossfade time=200]
[wt canskip=false]

[unlocksnapshot]
[unlocklink]

[return]


*krclick_dataload
; データを読み込む
; なんでここで読むかというと、krclick_obj 中で読むと、レイヤが invalidate
; されたりしてエラーになることがあるから、一度 KAG に戻るようにしたわけで。
[eval exp="kag.loadBookMark(tf.loadbookmarknum)"]
[s]
