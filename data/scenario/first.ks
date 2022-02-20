;===============================================================================
; 最初に読み込まれるシナリオファイル
;===============================================================================
[position layer=0 visible=false page=fore]
[wait time=200]

;===============================================================================
; この辺りにマクロ定義を記述すると良いでしょう

;▼TJS関数群
[call storage="TJSFunctions.ks"]

;▼KLayers(汎用レイヤーパーツ)
[call storage="KLayers.ks"]

;▼表示メッセージ保存プラグイン
[call storage="MessageStore.ks"]

;▼右クリックルーチン(ロード・セーブ・コンフィグ画面)サンプル
[call storage="Krclick.ks"]

;▼システムボタンプラグイン
[call storage="ExtSystemButton.ks"]

[call storage="SaveAnywhere.ks"]
[call storage="macro.ks"]

; マクロ定義ここまで
;===============================================================================

; タイトル画面のサンプルシナリオへ
[loadplugin module="wuvorbis.dll"]
[image layer=0 page=fore storage=title.jpg visible=true left=30 top=100]
[playse storage="冬あとパルクール"]
[ws]
[freeimage layer="0"] 
[jump storage="title.ks"]
