#|

●ライブラリ概要
スムーススクロールツール

http://www2.ocn.ne.jp/~cheerful/script/index.html
TKI

○機能
急な動きを極力抑えて、スムーズなwindowスクロールを実現します。
画面が急に変わるような雑な動きはなく、たくさん移動したいときは速く、スクロール終了間際はゆっくりスクロールします。

FireFox アドオンの 「Yet Another Smooth Scrolling」に近いです。

●影響

mouse-wheel-handlerの設定を置き換えます。
default:mouse-wheel-scroll
↓    ↓    ↓
このツール： my-mouse-scroll

○依存関係
xyzzyの標準機能で大丈夫なはず

○バッティング
ホイール スクロール系の lispをいれている人はこの変数をチェックしてみてください。
使っていたらバッティングするので、うまくラッピングしてください。
mouse-wheel-handler

この標準モジュールの上書き
"page"モジュール  "editor"パッケージ next-page


○ブルって止まらないとき、なんかスクロールしないとき
M-x smooth-scroll-reset
と押すと情報がリセットされて止まるはず

一応limit付けています。


○ちなみにマウスのホイール設定では
私のwindowsで9が設定されています。

●インストール

site-lisp/配下に .lファイルを置き
.xyzzy に (lood-library "smooth-scroll.l")とするだけ。
あとはホイールでスクロールしてみてください。


○カスタマイズ可能変数

*scroll-smoothly-property-list*
デフォルトでは4つ設定パターンリストが定義されています。
それぞれのリストの中の意味は以下のとおり

;1.スムースに動かす頻度(sec) 小さいほどちょこまか
;2.スクロール量分解数   大きいほどちょこまか
;3.スムースに動かす初動幅   小さいほどちょこまか
;4.スムースに動かす最終幅(最後にカチッとなる)   小さいほどちょこまか
;5.ラベル (お好きなように)


○キーによるスクロール(置き換え)
以下の"page"モジュールを置き換えると C-v , M-v , PageDown ,PageUpもスムースになります。
ed::next-page ： 置き換えいらない人は消しちゃってください。

●アンインストール
とりあえず、一般的な削除以外では

以下のスクロールの設定を戻しておいてください。
(setq-default mouse-wheel-handler 'mouse-wheel-scroll )


●履歴
2010/09/11 他のwindowをスクロールするバグを修正
           マウスアクションがなかった時にpopupをしないようにした。
2010/09/08 windowがなくなってた時の対処を追加
2010/09/06 行折り返しの時、バウンス処理をしてしまうバグ対応
バッファが切り替わったらすぐ終了させた。
2020/08/16 加速度変数も付加。
2020/08/13 バウンスしない変数も付加。
2020/08/13 バウンスさせるようにした。
2020/08/11 移動幅タイプを用意した。
2020/08/11 移動幅を変えられるようにした。
2020/08/11 作成

|#
;--------------------------------------------------------------------------------------------------------

(provide "smooth-scroll")

(require "page")
(require "mouse")

(in-package "editor")

(export '(
          *scroll-smoothly-property-list* *scroll-smoothly-bounce* *scroll-smoothly-accel*
          ;*scroll-smoothly-interval* *scroll-smoothlyness* *scroll-initial-smoothlyness* *scroll-last-smoothlyness*
          my-mouse-scroll smooth-scroll-start smooth-scroll-reset smooth-scroll-property-toggle smooth-scroll-property-print
          ))


;---------------------------------------------
;内部変数(カスタマイズ可)


(defvar *scroll-smoothly-property-list*
  (list '(0.03  8 3 1 'default)
        '(0.02  3 3 2  'speedy)
        '(0.01 12 2 1  'sligtly)
        '(0.3   3 6 3  'clearyView )))
;数字の意味は左から順に下記参照

;上のリストで上書きされます。
;1.スムースに動かす頻度(sec) 小さいほどちょこまか
;2.スクロール量分解数   大きいほどちょこまか
;3.スムースに動かす初動幅   小さいほどちょこまか
;4.スムースに動かす最終幅(最後にカチッとなる)   小さいほどちょこまか
;5.ラベル (お好きなように)

;端っこに来たときバウンスさせるかどうか
(defvar *scroll-smoothly-bounce* t)

;マウス加速率  n倍
(defvar *scroll-smoothly-accel* 1)

;---------------------------------------------
;内部変数
(defvar *scroll-smoothly* 0)
(defvar *scroll-smoothly-window* nil)
(defvar *scroll-smoothly-number* 0)
(defvar *scroll-smoothly-property-type* 0)

;スムースに動かす頻度(sec) 小さいほどちょこまか
(defvar *scroll-smoothly-interval* 0.03)
;スクロール量分解数   大きいほどちょこまか
(defvar *scroll-smoothlyness* 8)
;スムースに動かす初動幅   小さいほどちょこまか
(defvar *scroll-initial-smoothlyness* 3)
;スムースに動かす最終幅(最後にカチッとなる)   小さいほどちょこまか
(defvar *scroll-last-smoothlyness* 1);あまり小さいとブルブルして収束しないかも
(defvar *scroll-type-label* 'default)

;--------------------------------------------------------------------------------------------------------
;関数群

;初回イベント起動時のスクロール幅処理
;(標準関数の形ほぼそのまま)
(defun my-mouse-scroll (window n lines)
  (or lines
      (setq lines (window-lines window)))

  (smooth-scroll-start window (* n lines *scroll-smoothly-accel*))
  (continue-pre-selection)
  t)

;初回イベント起動時(上記のサブ関数)
;既に起動しているか、指定ないかの処理
(defun smooth-scroll-start (&optional window arg)
  (interactive)

  (if (= 0 *scroll-smoothly*)
      ;timer 起動していない
    (progn
      (setq *scroll-smoothly-number* 0);limitter
      (smooth-scroll window arg)
      ;未だ残りがある
      (if (/= 0 *scroll-smoothly*)
          (progn
            (setq *scroll-smoothly-window* window)
            (start-timer *scroll-smoothly-interval* 'smooth-scroll nil))))
    ;timer 起動中
    (progn
      (if (equal *scroll-smoothly-window* window)
          (setq *scroll-smoothly* (+ *scroll-smoothly* arg))))))

;実際のスクロール処理をする部分
;(初回(smooth-scroll-start)と、継続動作中(timer)に呼ばれる)
(defun smooth-scroll (&optional window arg)
  (unless window (setq window *scroll-smoothly-window*))
  (unless arg (setq arg 0))

  ;windowが変わったら停止
  (if (and *scroll-smoothly-window* 
           (not (eq *scroll-smoothly-window* (selected-window))))
      (progn
       (ignore-errors
        (if (windowp *scroll-smoothly-window*)
         (smooth-scroll-window *scroll-smoothly-window* *scroll-smoothly*)))
        (smooth-scroll-reset)))

  (setq *scroll-smoothly* (+ arg *scroll-smoothly*))

  (let ((cl (current-virtual-line-number)))
    (let ((sc))
      ;scroll size
      (setq sc
            (cond
             ;初回
             ((< *scroll-smoothly-number* 2)
              (floor (* (+ (/ *scroll-smoothly-number* 3) *scroll-initial-smoothlyness*) (if (> 0 *scroll-smoothly*) -1 1))))
             ;途中(立ち上がり)
             ((< *scroll-smoothly-number* (/ *scroll-smoothlyness* 2))
              (floor (/ *scroll-smoothly* (+ *scroll-smoothlyness* (/ *scroll-smoothly-number* 3)))))
             ;途中
             ((> (abs *scroll-smoothly*) *scroll-last-smoothlyness*)
              (floor (/ *scroll-smoothly* *scroll-smoothlyness*)))
             ;最後:残り全部
             (t  *scroll-smoothly*)))
      (if (= 0 sc) (setq sc (if (> 0 *scroll-smoothly*) -1 1)))

      ;scroll
      (smooth-scroll-window window sc)
      (setq *scroll-smoothly* (- *scroll-smoothly* sc)))

    ;事後-------------------------------
    ;limitter
    (setq *scroll-smoothly-number* (+ 1 *scroll-smoothly-number*))
    (if (> *scroll-smoothly-number* 300)
        (let (time-over-sc)
          (setq time-over-sc (* (if (> 0 *scroll-smoothly*) -1 1) (min 3 (abs *scroll-smoothly*))))
          (progn(smooth-scroll-window window time-over-sc)(setq *scroll-smoothly* (- *scroll-smoothly* time-over-sc)))))

    ;完了チェック
    (if (= 0 *scroll-smoothly*)
        (stop-timer 'smooth-scroll))

    ;あと端っこにきら終了[バウンス]させるとか
    (if (= cl (current-virtual-line-number))
        (setq *scroll-smoothly*
              (if *scroll-smoothly-bounce*
                  (floor (* *scroll-smoothly*
                            (if (< 0 *scroll-smoothly*) -0.3
                              (if (< *scroll-smoothly* -11) -0.04 -0.2))))
                0))))
  (refresh-screen)
  (continue-pre-selection))


;スムーススクロールリセッター
(defun smooth-scroll-reset ()
  (interactive)
  (stop-timer 'smooth-scroll)
  (setq *scroll-smoothly* 0
        *scroll-smoothly-number* 0))

(defun smooth-scroll-window (window size)
  (with-selected-window
    (set-window window)
    (scroll-window size)))

(defun smooth-scroll-property-toggle()
  (interactive)
  (let ((li))
    (setq li (nth *scroll-smoothly-property-type* *scroll-smoothly-property-list*))
    (setq *scroll-smoothly-interval* (first li)
          *scroll-smoothlyness*(second li)
          *scroll-initial-smoothlyness* (third li)
          *scroll-last-smoothlyness*  (fourth li)
          *scroll-type-label* (fifth li))

    (message "smooth scroll property changed[~A]:~A" *scroll-smoothly-property-type* *scroll-type-label*)
    (setq *scroll-smoothly-property-type* (mod (+ 1 *scroll-smoothly-property-type*) (length *scroll-smoothly-property-list*)))))

;初回だけセットする。
(if (not (boundp '*scroll-smoothly-interval*))
    (smooth-scroll-property-toggle))

(defun smooth-scroll-property-print ()
  (interactive)
  (message "smooth scroll property changed[~A]:~A" *scroll-smoothly-property-type* *scroll-type-label*))


;page モジュールの置き換え

(defun ed::next-page (&optional (arg 1))
  (interactive)
  (cond ((smooth-scroll-start (selected-window)(* (max (if *page-scroll-half-window*
                                                           (truncate (window-height) 2)
                                                         (- (window-height) *next-screen-context-lines*))
                                                       1)
                                                  arg)))
        ((or *page-scroll-keep-window-position*
             (zerop arg)
             (if (plusp arg) (eobp) (bobp)))
         nil)
        (t
         (goto-char (if (plusp arg) (point-max) (point-min))))))


;初期設定(xyzzyからのイベント起動元) ;うまく言っていない
;(or (boundp 'mouse-wheel-handler)
(setq-default mouse-wheel-handler 'ed::my-mouse-scroll) ;うまく言っていない。







