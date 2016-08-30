<meta charset="UTF-8">

MJZhengMa
===
Mac OSX上的一个郑码输入方案

Project home
---
[Github](https://github.com/mjsaka/MJZhengMa)

License
---
The GPLv3 License

Features
===
- 郑码、拼音、英文混输，拼音只支持输入单字，不支持词语和整句。
- 编码提示：郑码候选提示后续编码，拼音候选提示郑码编码。
- 4码时，候选词仅有郑码则自动上屏。
- 手动造词shift+space开启造词模式。
- shift键切换英文输入模式。
- 回车键上屏编码。

Install
===
- 由于版权问题，不提供郑码码表，请自行将郑码码表放至~/.config/MJZhengMa/Base.txt，文件编码为utf-8，格式为"编码 字词 词频"，按照编码升序排序，编码相同的再按词频从高到低排序。
- 想自定义拼音码表的话，可将拼音码表放至~/.config/MJZhengMa/PYDict.txt，文件编码为utf-8，格式为"拼音编码 字词 词频 郑码编码"，排序同郑码码表。
