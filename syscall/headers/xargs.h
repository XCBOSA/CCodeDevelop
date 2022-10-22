/*
 filesummary.CH: 提供可变参数函数获取参数的方法
 filesummary.EN: Provide methods to get access function parameters
 CH: 参数迭代器
 EN: Parameter iterator
 */
typedef builtin xa_list;

/*
 CH: 表示参数的对其字节数
 EN: Represents the align bytes of the parameters
 */
const size_t XA_ALIGN;

/*
 CH: 获取一个大小在对齐后的大小
 EN: Get the size after align
 */
long xa_align_of(size_t size);

/*
 CH: 开启一个迭代器，并将其指向变长参数的前一个参数位置
 EN: Start a iterator, point it to the first position of the var argument table
 list.CH: 参数迭代器实例
 list.EN: Iterator Instance
 begin_size.CH: 首个确定的参数大小
 begin_size.EN: The first known parameter size
 begin.CH: 首个确定的参数
 begin.EN: The first known parameter
 */
void xa_start(xa_list &list, void* begin, size_t begin_size);

/*
 CH: 获取下一个参数
 EN: Get the next argument
 list.CH: 参数迭代器实例
 list.EN: Iterator Instance
 size.CH: 新参数大小
 size.EN: New argument size
 copyto.CH: 要将新参数拷贝到的变量地址
 copyto.EN: The address of the variable to copy the new parameter to
 */
void xa_arg(xa_list &list, size_t size, void* copyto);

/*
 CH: 关闭参数迭代器
 EN: Close the iterator instance
 */
void xa_end(xa_list &list);
