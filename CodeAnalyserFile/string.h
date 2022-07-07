/*
 filesummary.CH: 提供字符串操作函数
 filesummary.EN: Provide string operations
 CH: 复制字符串
 EN: Copy string
 dst.CH: 目的字符串
 dst.EN: Dest string
 src.CH: 源字符串
 src.EN: Source string
 */
void  strcpy(char *dst, char *src);

/*
 CH: 复制字符串
 EN: Copy string
 dst.CH: 目的字符串
 dst.EN: Dest string
 src.CH: 源字符串
 src.EN: Source string
 n.CH: 拷贝的长度
 n.EN: The length of the string
 */
void  strncpy(char *dst, char *src, int n);

/*
 CH: 计算两个字符串的标准差值（注意：等于0表示字符串一致，而非等于布尔值true）
 EN: Compare the given string (Notice: Return 0 indicate same)
 lhs.CH: 字符串1
 lhs.EN: String 1
 rhs.CH: 字符串2
 lhs.EN: String 2
 */
int  strcmp(char *lhs, char *rhs);

/*
 CH: 计算两个字符串的标准差值（注意：等于0表示字符串一致，而非等于布尔值true）
 EN: Compare the given string (Notice: Return 0 indicate same)
 lhs.CH: 字符串1
 lhs.EN: String 1
 rhs.CH: 字符串2
 lhs.EN: String 2
 n.CH: 对比的长度
 n.EN: The length of the string
 */
int  strncmp(char *lhs, char *rhs, int n);

/*
 CH: 把 src 所指向的字符串追加到 dest 所指向的字符串的结尾 (dest += src)
 EN: Add src to the end of dest (dest += src)
 dest.CH: 字符串dest
 dest.EN: String dest
 src.CH: 字符串src
 src.EN: String src
 */
void  strcat(char *dest, char *src);

/*
 CH: 获取字符串s从第一个字符c开始的子串
 EN: Return the string's substring from character c
 s.CH: 字符串
 s.EN: String
 c.CH: 给定字符
 c.EN: Given char
 */
char* index(char *s, int c);

/*
 CH: 获取字符串s从最后一个字符c开始的子串
 EN: Return the string's substring from character c
 s.CH: 字符串
 s.EN: String
 c.CH: 给定字符
 c.EN: Given char
 */
char* rindex(char *s, int c);

/*
 CH: 获取字符串长度
 EN: Return the length of string
 arg1.CH: 字符串
 arg1.EN: String
 */
int  strlen(char *);

/*
 CH: 将一段内存设置为val
 EN: Set the memory range to val
 arg1.CH: 内存
 arg1.EN: Memory
 val.CH: 写入的值
 val.EN: Write value
 count.CH: 写入的长度
 count.EN: The length of writing
 */
void  memset(void *, int val, int count);

/*
 CH: 拷贝内存
 EN: Copy memory
 dst.CH: 目的地址
 dst.EN: Dest pointer
 src.CH: 源地址
 src.EN: Source pointer
 count.CH: 拷贝长度
 count.EN: The length to copy
 */
void  memcpy(void *dst, void *src, int count);

/*
 CH: 计算两个字符串的标准差值，比较count个长度
 EN: Compare the given two [memory, memory+count)
 lhs.CH: 内存1
 lhs.EN: Memory 1
 rhs.CH: 内存2
 lhs.EN: Memory 2
 count.CH: 比较长度
 count.EN: Compare length
 */
int  memcmp(void *lhs, void *rhs, int count);

/*
 CH: 在参数 str 所指向的字符串中搜索第一次出现字符 c（一个无符号字符）的位置
 EN: Searches the string pointed to by the argument str for the first occurrence of the character c (an unsigned character)
 c.CH: 给定字符
 c.EN: Given char
 */
char* strchr(char *s, int c);

/*
 CH: 检索字符串 s 开头连续有几个字符都不含字符串 charset 中的字符
 EN: Retrieve several consecutive characters at the beginning of the string s that do not contain the characters in the string charset
 s.CH: 字符串s
 s.EN: String s
 charset.CH: 字符集合串
 charset.EN: Char set string
 */
size_t strcspn(char *s, char *charset);

/*
 CH: 把 src 所指向的字符串追加到 dest 所指向的字符串的结尾，直到 n 字符长度为止
 EN: Appends the string pointed to by src to the end of the string pointed to by dest until n characters long
 dest.CH: 目的串
 dest.EN: Dest string
 src.CH: 字符串
 src.EN: String
 n.CH: 长度
 n.EN: Length
 */
char* strncat(char *dest, char *src, size_t n);

/*
 CH: 检索字符串 s 中第一个匹配字符串 charset 中字符的字符，不包含空结束字符
 EN: Retrieves the first character in the string s that matches the characters in the string charset, excluding the null terminator
 s.CH: 字符串
 s.EN: String
 charset.CH: 字符集合串
 charset.EN: Char set String
 */
char* strpbrk(char *s, char *charset);

/*
 CH: 在参数 s 所指向的字符串中搜索最后一次出现字符 __c（一个无符号字符）的位置
 EN: Searches the string pointed to by the argument s for the position of the last occurrence of the character __c (an unsigned character)
 s.CH: 字符串
 s.EN: String
 __c.CH: 一个无符号字符
 __c.EN: An unsigned character
 */
char* strrchr(char *s, int __c);

/*
 CH: 检索字符串 s 中第一个不在字符串 charset 中出现的字符下标
 EN: Retrieves the subscript of the first character in the string s that does not appear in the string charset
 s.CH: 字符串
 s.EN: String
 charset.CH: 字符集合串
 charset.EN: Char set String
 */
size_t strspn(char *s, char *charset);

/*
 CH: 在字符串 big 中查找第一次出现字符串 little 的位置，不包含终止符 '\0'
 EN: Find the first occurrence of the string little in the string big, excluding the terminator '\0'
 big.CH: 字符串big
 big.EN: String big
 little.CH: 字符串little
 little.EN: String little
 */
char* strstr(char *big, char *little);

/*
 CH: 分解字符串 str 为一组字符串，sep 为分隔符
 EN: Decompose the string str into a set of strings, sep is the delimiter
 str.CH: 字符串str
 str.EN: String str
 sep.CH: 分隔符
 sep.EN: Seperator
 */
char* strtok(char *str, char *sep);

/*
 CH: 根据程序当前的区域选项中的 LC_COLLATE 来转换字符串 src 的前 n 个字符，并把它们放置在字符串 dest 中
 EN: Convert the first n characters of the string src according to LC_COLLATE in the program's current locale options and place them in the string dest
 dest.CH: 目的串
 dest.EN: Dest string
 src.CH: 源字符串
 src.EN: Source string
 n.CH: 长度
 n.EN: length
 */
size_t strxfrm(char *dest, char *src, size_t n);
