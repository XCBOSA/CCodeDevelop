/*
 filesummary.CH: 提供用于判断字符类型的函数
 filesummary.EN: Provide some function used to check character type
 CH: 检查字符是否是字母或数字
 EN: Check is alpha or number
 arg1.CH: 要检查的字符
 arg1.EN: Char to check
 */
int     isalnum(int);

/*
 CH: 检查字符是否是字母
 EN: Check is alpha
 arg1.CH: 要检查的字符
 arg1.EN: Char to check
 */
int     isalpha(int);

/*
 CH: 检查字符是否是空字符
 EN: Check is blank
 arg1.CH: 要检查的字符
 arg1.EN: Char to check
 */
int     isblank(int);

/*
 CH: 检查字符是否是控制字符
 EN: Check is controllable char
 arg1.CH: 要检查的字符
 arg1.EN: Char to check
 */
int     iscntrl(int);

/*
 CH: 检查字符是否是十进制数字
 EN: Check is decimal
 arg1.CH: 要检查的字符
 arg1.EN: Char to check
 */
int     isdigit(int);

/*
 CH: 检查字符是否有图形表示法
 EN: Check has graph
 arg1.CH: 要检查的字符
 arg1.EN: Char to check
 */
int     isgraph(int);

/*
 CH: 检查字符是否是小写字符
 EN: Check is lower alpha
 arg1.CH: 要检查的字符
 arg1.EN: Char to check
 */
int     islower(int);

/*
 CH: 检查字符是否是可打印的
 EN: Check is print-able
 arg1.CH: 要检查的字符
 arg1.EN: Char to check
 */
int     isprint(int);

/*
 CH: 检查字符是否是标点符号
 EN: Check is punct
 arg1.CH: 要检查的字符
 arg1.EN: Char to check
 */
int     ispunct(int);

/*
 CH: 检查字符是否是空白字符
 EN: Check is space
 arg1.CH: 要检查的字符
 arg1.EN: Char to check
 */
int     isspace(int);

/*
 CH: 检查字符是否是大写字符
 EN: Check is upper alpha
 arg1.CH: 要检查的字符
 arg1.EN: Char to check
 */
int     isupper(int);

/*
 CH: 检查字符是否是十六进制数字
 EN: Check is hex
 arg1.CH: 要检查的字符
 arg1.EN: Char to check
 */
int     isxdigit(int);

/*
 CH: 将字符转换为小写字符
 EN: Get the lower alpha of input
 arg1.CH: 要检查的字符
 arg1.EN: Char to check
 */
int     tolower(int);

/*
 CH: 将字符转换为大写字符
 EN: Get the upper alpha of input
 arg1.CH: 要检查的字符
 arg1.EN: Char to check
 */
int     toupper(int);

/*
 CH: 检查字符是否是ASCII字符
 EN: Check is ASCII
 arg1.CH: 要检查的字符
 arg1.EN: Char to check
 */
int     isascii(int);

/*
 CH: 将字符转换为ASCII字符
 EN: Transfer to ASCII
 arg1.CH: 要检查的字符
 arg1.EN: Char to check
 */
int     toascii(int);

/*
 CH: 将字符转换为小写字符
 EN: Get the lower alpha of input
 arg1.CH: 要检查的字符
 arg1.EN: Char to check
 */
int     _tolower(int);

/*
 CH: 将字符转换为大写字符
 EN: Get the upper alpha of input
 arg1.CH: 要检查的字符
 arg1.EN: Char to check
 */
int     _toupper(int);

/*
 CH: 将字符转换为整数
 EN: Get the integer of input
 arg1.CH: 要检查的字符
 arg1.EN: Char to check
 */
int     digittoint(int);

/*
 CH: 检查字符是否是十六进制数字
 EN: Check is hex
 arg1.CH: 要检查的字符
 arg1.EN: Char to check
 */
int     ishexnumber(int);

/*
 CH: 检查字符是否是十六进制数字
 EN: Check is hex
 arg1.CH: 要检查的字符
 arg1.EN: Char to check
 */
int     isideogram(int);

/*
 CH: 检查字符是否是数字
 EN: Check is number
 arg1.CH: 要检查的字符
 arg1.EN: Char to check
 */
int     isnumber(int);
int     isphonogram(int);
int     isrune(int);

/*
 CH: 检查字符是否是特殊字符
 EN: Check is special
 arg1.CH: 要检查的字符
 arg1.EN: Char to check
 */
int     isspecial(int);
