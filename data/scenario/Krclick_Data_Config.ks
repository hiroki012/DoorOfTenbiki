; コンフィグ画面設定 ##########################################################
;
; Krclick.ks からのみ読み込まれる
;
; init_config_screen_values() を呼ぶと、
; .config_screen に、コンフィグ画面を構成するレイヤデータの配列を作って返す。
;

; 2013/12/05	0.2	ちょっとだけ位置調整
; 2013/12/02	0.1	初期リリース

[iscript]


// コンフィグ画面 ###########################################################
var config_screen = [];

// 初期化する。こうしないと、画面切り替えて戻った時に「最初に設定した値」に
// 戻ってしまうため。
function init_config_screen_values()
{
config_screen = [

	// 背景
	// 降順に表示するので、背景(=他のレイヤのparent)は最後に定義する
	%[	classid		: "KClickableLayer",
		name		: "config_background",
		left		: rposx(0),
		top		: rposy(0),
		width		: rposx(640),
		height		: rposy(480),
//		graphic		: "wall_menu",
		cursor		: crArrow,
		clickablemb	: VK_RBUTTON,
		ncaction	: NCACTION_NOACTION,
		onrrelease	: ".krclick_obj.moveto('back', .krclick_obj.CLEAR)"
	],

	// 「メッセージ表示速度」
	%[	classid		: "KLayer",
		name		: "messagespeed_str",
		parent		: "config_background",
		texthalign	: 'left',
		left		: rposx(40),
		top		: rposy(45),
		width		: rposx(160),
		height		: rposy(25),
		kfont		: %[ height: rposy(18) ],
		text		: "メッセージ表示速度"
	],
	// 「未読」
	%[	classid		: "KLayer",
		name		: "messagespeed1_str",
		parent		: "config_background",
		left		: rposx(50),
		top		: rposy(80),
		width		: rposx(48),
		height		: rposy(25),
		text		: "未読"
	],
	// メッセージ表示速度(未読)スライダー
	%[	classid		: "KSliderLayer",
		name		: "messagespeed1",
		parent		: "config_background",
		left		: rposx(100),
		top		: rposy(80),
		width		: rposx(200),
		height		: rposy(25),
		color		: 0,	// clNone は 0(透明)じゃないので注意
//		tabgraphic	: "slider_tab",
		hval		: getMessageSpeed1(),
		hstep		: 1,
		hmin		: 0,
		hmax		: 4,
		hintflg		: true,
		onchangefunc	: "setMessageSpeed1"
	],
	// ページ末まで一気にcheckbox
	%[	classid		: "KCheckBoxLayer",
		name		: "messagespeed1_pageskip",
		parent		: "config_background",
		left		: rposx(316),
		top		: rposy(84),
		width		: rposx(16),
		height		: rposy(16),
//		basegraphic	: "button_menu_checkbox",
//		graphic		: "button_menu_check",
		checked		: kag.chNonStopToPageBreak,
		oncheck		: "kag.onChNonStopToPageBreakItemClick()",
		onuncheck	: "kag.onChNonStopToPageBreakItemClick()"
	],
	// 「ページ末まで一気に」
	%[	classid		: "KLayer",
		name		: "messagespeed1_pageskip_str",
		parent		: "config_background",
		left		: rposx(340),
		top		: rposy(84),
		width		: rposx(140),
		height		: rposy(16),
		texthalign	: 'left',
		text		: "ページ末まで一気に"
	],


	// 「既読」
	%[	classid		: "KLayer",
		name		: "messagespeed2_str",
		parent		: "config_background",
		left		: rposx(50),
		top		: rposy(130),
		width		: rposx(48),
		height		: rposy(25),
		text		: "既読"
	],
	// メッセージ表示速度(既読)
	%[	classid		: "KSliderLayer",
		name		: "messagespeed2",
		parent		: "config_background",
		left		: rposx(100),
		top		: rposy(130),
		width		: rposx(200),
		height		: rposy(25),
		color		: 0,	// clNone は 0(透明)じゃないので注意
//		tabgraphic	: "slider_tab",
		hval		: getMessageSpeed2(),
		hstep		: 1,
		hmin		: 0,
		hmax		: 4,
		hintflg		: true,
		onchangefunc	: "setMessageSpeed2"
	],
	// ページ末まで一気にcheckbox
	%[	classid		: "KCheckBoxLayer",
		name		: "messagespeed2_pageskip",
		parent		: "config_background",
		left		: rposx(316),
		top		: rposy(134),
		width		: rposx(16),
		height		: rposy(16),
//		basegraphic	: "button_menu_checkbox",
//		graphic		: "button_menu_check",
		checked		: kag.ch2ndNonStopToPageBreak,
		oncheck		: "kag.onCh2ndNonStopToPageBreakItemClick()",
		onuncheck	: "kag.onCh2ndNonStopToPageBreakItemClick()"
	],
	// 「ページ末まで一気に」
	%[	classid		: "KLayer",
		name		: "messagespeed2_pageskip_str",
		parent		: "config_background",
		left		: rposx(340),
		top		: rposy(134),
		width		: rposx(140),
		height		: rposy(16),
		texthalign	: 'left',
		text		: "ページ末まで一気に"
	],

	// 「自動」
	%[	classid		: "KLayer",
		name		: "messagespeed_auto_str",
		parent		: "config_background",
		left		: rposx(50),
		top		: rposy(180),
		width		: rposx(48),
		height		: rposy(25),
		text		: "自動"
	],
	// オートプレイ再生速度
	%[	classid		: "KSliderLayer",
		name		: "messagespeed_auto",
		parent		: "config_background",
		left		: rposx(100),
		top		: rposy(180),
		width		: rposx(200),
		height		: rposy(25),
		color		: 0,	// clNone は 0(透明)じゃないので注意
//		tabgraphic	: "slider_tab",
		hval		: getMessageSpeedAuto(),
		hstep		: 1,
		hmin		: 0,
		hmax		: 4,
		hintflg		: true,
		onchangefunc	: "setMessageSpeedAuto"
	],

	// 「画面設定」
	%[	classid		: "KLayer",
		name		: "messagespeed_str",
		parent		: "config_background",
		texthalign	: 'left',
		left		: rposx(40),
		top		: rposy(230),
		width		: rposx(160),
		height		: rposy(25),
		kfont		: %[ height: rposy(18) ],
		text		: "画面設定"
	],

	// フルスクリーン・ウィンドウ表示 ラジオボタン
	%[	classid		: "KRadioButtonLayer",
		name		: "windowconfig",
		parent		: "config_background",
		left		: rposx(100),
		top		: rposy(260),
		width		: rposx(160),
		height		: rposy(25),
		buttonnum	: 2,
		space		: 10,
		color		: 0,
		pushed		: kag.fullScreened ? 1 : 0,
//		oncheckfunc	:
		buttons	: [
			%[
			   text    : "ウィンドウ",
			// ホントはここに条件要らないんだけど、WindowResizable.ksが、二度押しすると1倍の大きさに戻しちゃうので追加。
			   oncheck : "kag.fullScreened && kag.onWindowedMenuItemClick()"
			],
			%[
			   text    : "フルスクリーン",
			   oncheck : "kag.fullScreened || kag.onFullScreenMenuItemClick()"
			]
		],
		buttonopts : %[
			width: 128
		]
	],


	// 「サウンド設定」
	%[	classid		: "KLayer",
		name		: "messagespeed_str",
		parent		: "config_background",
		texthalign	: 'left',
		left		: rposx(40),
		top		: rposy(313),
		width		: rposx(160),
		height		: rposy(25),
	 	kfont		: %[ height: rposy(18) ],
		text		: "サウンド設定"
	],
	// 「BGM」
	%[	classid		: "KLayer",
		name		: "bgmname",
		parent		: "config_background",
		left		: rposx(50),
		top		: rposy(353),
		width		: rposx(48),
		height		: rposy(16),
		text		: "ＢＧＭ"
	],
	// BGM音量 スライダー
	%[	classid		: "KSliderLayer",
		name		: "bgmslider",
		parent		: "config_background",
		left		: rposx(100),
		top		: rposy(350),
		width		: rposx(200),
		height		: rposy(25),
		color		: 0,	// clNone は 0(透明)じゃないので注意
//		tabgraphic	: "slider_tab",
		hval		: getBgmVolume(),
		hmax		: 100,
		hmin		: 0,
		hintflg		: true,
		hstep		: 1,
		onchangefunc	: "setBgmVolume" //関数を呼ぶ
	],
	// BGM音量 現在の値
	%[	classid		: "KLayer",
		name		: "bgmvval",
		parent		: "config_background",
		left		: rposx(305),
		top		: rposy(350),
		width		: rposx(32),
		height		: rposy(25),
		color		: 0,	// clNone は 0(透明)じゃないので注意
		text		: string(getBgmVolume()),
		kfont		: %[ height: rposy(14) ]
	],
	// BGM音量 mute
	%[	classid		: "KCheckBoxLayer",
		name		: "bgmmute",
		parent		: "config_background",
		left		: rposx(350),
		top		: rposy(355),
		width		: rposx(16),
		height		: rposy(16),
//		basegraphic	: "button_menu_checkbox",
//		graphic		: "button_menu_check",
		checked		: sf.rcMenu.BgmMute,
		oncheck		: "sf.rcMenu.BgmMute = true, setBgmVolume(0)",
		onuncheck	: "sf.rcMenu.BgmMute = false,
				   setBgmVolume(sf.rcMenu.BgmVolume)"
	],
	// BGM「消音」
	%[	classid		: "KLayer",
		name		: "bgmmutestr",
		parent		: "config_background",
		left		: rposx(372),
		top		: rposy(353),
		width		: rposx(32),
		height		: rposy(16),
		text		: "消音"
	],

	// 「効果音」
	%[	classid		: "KLayer",
		name		: "bgmname",
		parent		: "config_background",
		left		: rposx(50),
		top		: rposy(403),
		width		: rposx(48),
		height		: rposy(16),
//		basegraphic	: "button_menu_checkbox",
//		graphic		: "button_menu_check",
		text		: "効果音"
	],
	// SE音量 スライダー
	%[	classid		: "KSliderLayer",
		name		: "seslider",
		parent		: "config_background",
		left		: rposx(100),
		top		: rposy(400),
		width		: rposx(200),
		height		: rposy(25),
		color		: 0,	// clNone は 0(透明)じゃないので注意
//		tabgraphic	: "slider_tab",
		hval		: getSeVolume(),
		hmax		: 100,
		hmin		: 0,
		hintflg		: true,
		hstep		: 1,
		onchangefunc	: "setSeVolume" //関数を呼ぶ
	],
	// SE音量 現在の値
	%[	classid		: "KLayer",
		name		: "sevval",
		parent		: "config_background",
		left		: rposx(305),
		top		: rposy(400),
		width		: rposx(32),
		height		: rposy(25),
		color		: 0,	// clNone は 0(透明)じゃないので注意
		text		: string(getSeVolume()),
		kfont		: %[ height: rposy(14) ]
	],
	// SE音量 mute
	%[	classid		: "KCheckBoxLayer",
		name		: "semute",
		parent		: "config_background",
		left		: rposx(350),
		top		: rposy(405),
		width		: rposx(16),
		height		: rposy(16),
//		basegraphic	: "button_menu_checkbox",
//		graphic		: "button_menu_check",
		checked		: sf.rcMenu.SeMute,
		oncheck		: "sf.rcMenu.SeMute = true, setSeVolume(0)",
		onuncheck	: "sf.rcMenu.SeMute = false,
				   setSeVolume(sf.rcMenu.SeVolume)"
	],
	// SE「消音」
	%[	classid		: "KLayer",
		name		: "bgmmutestr",
		parent		: "config_background",
		left		: rposx(372),
		top		: rposy(403),
		width		: rposx(32),
		height		: rposy(16),
		text		: "消音"
	],

	// 「セーブ」
	%[	classid		: "KAnimButtonLayer",
		name		: "game_save",
		parent		: "config_background",
		left		: rposx(480),
		top		: rposy(60),
		width		: rposx(120),
		height		: rposy(25),
		text		: "セーブ",
		enabled		: kag.canStore(),
//		graphic		: "button_menu_title",
		onclick		: ".krclick_obj.moveto('back', .krclick_obj.SAVE)"
	],

	// 「ロード」
	%[	classid		: "KAnimButtonLayer",
		name		: "game_load",
		parent		: "config_background",
		left		: rposx(480),
		top		: rposy(110),
		width		: rposx(120),
		height		: rposy(25),
		text		: "ロード",
		enabled		: kag.canRestore(),
//		graphic		: "button_menu_title",
		onclick		: ".krclick_obj.moveto('back', .krclick_obj.LOAD)"
	],

//	// 「メッセージを消す」
//	%[	classid		: "KAnimButtonLayer",
//		name		: "hide_message",
//		parent		: "config_background",
//		left		: rposx(480),
//		top		: rposy(160),
//		width		: rposx(120),
//		height		: rposy(25),
//		text		: "メッセージを消す",
////		graphic		: "button_menu_title",
//		onclick		: ".krclick_obj.moveto('back', .krclick_obj.CLEAR), kag.hideMessageLayerByUser()"
//	],

//	// 「履歴の表示」
//	%[	classid		: "KAnimButtonLayer",
//		name		: "display_history",
//		parent		: "config_background",
//		left		: rposx(480),
//		top		: rposy(210),
//		width		: rposx(120),
//		height		: rposy(25),
//		text		: "履歴を表示する",
////		graphic		: "button_menu_title",
//		onclick		: ".krclick_obj.moveto('back', .krclick_obj.CLEAR), kag.showHistoryByKey()"
//	],

	// 「一つ前へ戻る」
	%[	classid		: "KAnimButtonLayer",
		name		: "goto_prev",
		parent		: "config_background",
		left		: rposx(480),
		top		: rposy(260),
		width		: rposx(120),
		height		: rposy(25),
		text		: "一つ前へ戻る",
		enabled		: kag.isHistoryOfStoreAlive(),
//		graphic		: "button_menu_title",
		onclick		: "kag.goBackHistory()"
	],

	// 「タイトルへ戻る」
	%[	classid		: "KAnimButtonLayer",
		name		: "goto_title",
		parent		: "config_background",
		left		: rposx(480),
		top		: rposy(310),
		width		: rposx(120),
		height		: rposy(25),
		enabled		: kag.startAnchorEnabled,
		text		: "タイトルへ戻る",
//		graphic		: "button_menu_title",
		onclick		: "kag.goToStartWithAsk()"
	],

	// 「ゲーム終了」
	%[	classid		: "KAnimButtonLayer",
		name		: "exit_game",
		parent		: "config_background",
		left		: rposx(480),
		top		: rposy(360),
		width		: rposx(120),
		height		: rposy(25),
		text		: "ゲームを終了する",
//		graphic		: "button_menu_end",
		onclick		: "kag.closeByScript(%[ask:true])"
	],


	// コンフィグ画面を閉じる
	%[	classid		: "KAnimButtonLayer",
		name		: "close_config",
		parent		: "config_background",
		left		: rposx(480),
		top		: rposy(410),
		width		: rposx(120),
		height		: rposy(25),
		text		: "閉じる",
//		graphic		: "button_menu_close",
		showfocusimage	: true,
		onclick		: ".krclick_obj.moveto('back', .krclick_obj.CLEAR)"
	],

	// コンフィグ画面を閉じる(タイトルから遷移ver)
	%[	classid		: "KAnimButtonLayer",
		name		: "close_config_from_title",
		parent		: "config_background",
		left		: rposx(480),
		top		: rposy(410),
		width		: rposx(120),
		height		: rposy(25),
		text		: "閉じる",
//		graphic		: "button_menu_close",
		showfocusimage	: true,
		onclick		: "kag.goToStart()"
	]
	//↑末尾に','があると、空の配列要素が追加されたことになるので注意
];

}

[endscript]

[return]
