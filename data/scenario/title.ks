;===============================================================================
; タイトル画面のサンプルシナリオ
;===============================================================================
*title|タイトル
[startanchor]
[clearvar]
[disablestore]
[history enabled="false" output="false"]
[loadplugin module="wuvorbis.dll"]
[position layer=base page=fore visible=true]
[wait time=200]

[delay speed="nowait"]
[link target="*start"]スタート[endlink][r]
;[link target="*load"]ロード[endlink][r]
;[if exp='Storages.isExistentStorage("%s/%s%d.bmp".sprintf(kag.saveDataLocation, kag.dataName, MBSystemPref.quickSaveBookMark))']
;	[link target="*continue"]コンティニュー[endlink][r]
;[endif]
[link target="*config"]コンフィグ[endlink][r]
[link target="*exit"]終了[endlink][r]
[delay speed="user"]
[s]

;-------------------------------------------------------------------------------
; 最初からスタート
*start
[ws]

[cm]
[history enabled="true" output="true"]
[jump storage="1.ks"]
[s]

;-------------------------------------------------------------------------------
; プレイデータをロード
*load
[cm]
;[eval exp="SystemManager.startPlayDataStorager('load')"]

;これもタイトルから遷移用のやつ作る。
[eval exp="kag.callExtraConductor('Krclick.ks','*krclick_load')"]
[waittrig name="CLOSE_BOOKMARK_WINDOW"]
[jump target="*title"]
[s]

;-------------------------------------------------------------------------------
; クイックロード
*continue
[cm]
[load place="&MBSystemPref.quickSaveBookMark" ask="false"]
[s]

;-------------------------------------------------------------------------------
; 環境設定
*config
[cm]
;[iscript]
;tf.config = new MBControlPanelContainer(kag, kag.fore.base);
;MBSystem.addTempObject(tf.config);
;[endscript]

;[store]
;[eval exp="MBSystem.removeTempObject(tf.config);"]
[eval exp="kag.callExtraConductor('Krclick.ks','*krclick_config_from_title')"]
[s]

;-------------------------------------------------------------------------------
; ゲーム終了
*exit
[close]
[unlocklink]
[s]
