; 多重読み込みを防止
[return cond="typeof(global.MessageStore_obj) != 'undefined'"]

; MessageStore.ks
; 画面に表示されたメッセージを、f.messagestore に溜め込む
; セーブ時に画面上のメッセージを「文字列で」保存したい場合に使用する。
; 殆どのタグは無視されるが、[r]はそのままタグごと記録される。
; f.messagestore は [cm][ct] でクリアされる。[er]はms_noclearが指定されて
; いなければクリアされる
;
; 2016/10/17	0.4	・[ms_clear]タグを追加
; 2016/03/01	0.3	・メッセージ保存を一時停止できるように変更
; 2013/11/24	0.2	・RenameKAGTag.ksを利用しないように大幅修正
;			・終了時エラーを吐かないようにKAGPlugin化
; 2011/08/18	0.1	初期リリース


[iscript]

// ↓ここに現在メッセージレイヤに表示中の文字列が書き込まれる
f.messagestore = "";
// KAGPlugin内の変数ではなくf.として独立しているのは、この変数をそのまま
// セーブルーチン中で直接使用することがあるため。

class MessageStore extends KAGPlugin {
	var win;
	var pause = false;	// 一時停止中かどうか

	// コンストラクタ
	function MessageStore(w)
	{
		win = w;
		w.tagHandlers.messagestore_ch_org = w.tagHandlers.ch;
		w.tagHandlers.messagestore_cm_org = w.tagHandlers.cm;
		w.tagHandlers.messagestore_er_org = w.tagHandlers.er;
		w.tagHandlers.messagestore_r_org  = w.tagHandlers.r;

		w.tagHandlers.ch = ch_cus incontextof win;
		w.tagHandlers.cm = cm_cus incontextof win;
		w.tagHandlers.er = er_cus incontextof win;
		w.tagHandlers.r  = r_cus  incontextof win;
	}

	// デストラクタ
	function finalize()
	{
		if (!isvalid(win) || !isvalid(win.tagHandlers))
			return; // kagの方が先にinvalidateされたら以下を無視
		win.tagHandlers.ch = win.tagHandlers.messagestore_ch_org;
		win.tagHandlers.cm = win.tagHandlers.messagestore_cm_org;
		win.tagHandlers.er = win.tagHandlers.messagestore_er_org;
		win.tagHandlers.r  = win.tagHandlers.messagestore_r_org;

		delete win.tagHandlers.messagestore_ch_org;
		delete win.tagHandlers.messagestore_cm_org;
		delete win.tagHandlers.messagestore_er_org;
		delete win.tagHandlers.messagestore_r_org;
	}

	// オプション設定
	function setOptions(elm)
	{
		if (elm === void)
			return;

		pause = +elm.pause if (elm.pause !== void);
	}

	// kag.tagHandlers.chを乗っ取る関数
	function ch_cus(elm) // incontextof win
	{
		var ret = tagHandlers.messagestore_ch_org(elm);
		if (!.MessageStore_obj.pause &&
		    ret != -5 && ret != -3) // && historyWriteEnabledこれあると[eruby]で表示されないので削除。でもerubyはちゃんとhistoryに記録されるという不思議。[emb]に関係しているらしい
			f.messagestore += elm.text;
		return ret;
	}

	// kag.tagHandlers.cmを乗っ取る関数
	function cm_cus(elm) // incontextof win
	{
		f.messagestore = "" if (!.MessageStore_obj.pause);
		return tagHandlers.messagestore_cm_org(elm);
	}

	// kag.tagHandlers.ctを乗っ取る関数
	function ct_cus(elm) // incontextof win
	{
		f.messagestore = "" if (!.MessageStore_obj.pause);
		return tagHandlers.messagestore_ct_org(elm);
	}

	// kag.tagHandlers.erを乗っ取る関数
	function er_cus(elm) // incontextof win
	{
		if (!.MessageStore_obj.pause && (!elm || +elm.ms_noclear))
			f.messagestore = "";
		return tagHandlers.messagestore_er_org(elm);
	}

	// kag.tagHandlers.rを乗っ取る関数
	function r_cus(elm) // incontextof win
	{
		if (!.MessageStore_obj.pause && historyWriteEnabled)
			f.messagestore += '[r]';
		return tagHandlers.messagestore_r_org(elm);
	}

	// セーブ時
        function onStore(f, elm)
	{
		var dic = f.messagestore_opts = %[];
		dic.pause = pause;
		return dic;
	}

	// ロード時
        function onRestore(f, clear, elm)
	{
		var dic = f.messagestore_opts;
		if (dic === void) // ホントは無駄だが今後のために残しておく
			return;
		setOptions(dic);
	}
};


kag.addPlugin(.MessageStore_obj = new MessageStore(kag));

[endscript]

; オプション設定
[macro name=messagestore_setopt]
[eval exp=".MessageStore_obj.setOptions(mp)"]
[endmacro]

[macro name=ms_clear]
[eval exp="f.messagestore = ''"]
[endmacro]

[return]
