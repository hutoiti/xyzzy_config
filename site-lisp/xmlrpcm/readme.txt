$Id: readme.txt,v 1.9 2006/03/07 18:14:58 torihat Exp $

 xml-rpc-modoki

■ xml-rpc-modoki とは？

	xyzzy で XML-RPC を利用するライブラリ的なものです。
	利用条件等に関しては、LICENSE.txtをご覧下さい。

■ 動作環境

	xyzzy-0.2.2.235以降

	以下の拡張が必要です。別途インストールしてください。
		- xml-parser-modoki(0.0.0.5以降)
		- junk-library

■ インストール

	配布アーカイブを system-root 以下に展開してください。

■ 変更履歴

	[2006/03/08]
		・POPFile XML-RPC Interfaceを実装。（一部未テスト）
		  http://popfile.sourceforge.net/cgi-bin/wiki.pl?JP_POPFileModules/XmlRpc

	[2006/02/05]
		・typo の修正など。

	[2006/02/02]
		・Faultの処理を修正。
		・User-Agentを変更。

	[2006/01/21]
		・Trackback Ping 送信のバグを修正。

	[2006/01/14]
		・80以外のportにアクセスできないバグを修正。
		・Responseの解析時に応答が帰ってこなくなる場合があったのを修正。
		・Trackback Ping 送信。
		・Wiki RPC Interface 2を部分的に実装。
		・Base64送信時の扱いを変更。

	[2006/01/11]
		・初版
