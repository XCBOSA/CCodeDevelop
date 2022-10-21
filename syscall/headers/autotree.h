/*
 filesummary.CH: 一个由引用计数管理的智能树，包含拓展的C语法来快速创建和操作元素
 filesummary.EN: Representation an reference count managed tree, included extended C gramma to quick create and access it's node
 CH: 表示由AutoTree内存区管理的一棵树，或一个节点。可以是键值对、数组、字符串、整形、浮点型，其存储在AutoTree内存区并由引用计数管理。
 EN: Describing an AutoTree managed tree, or node. The value of it can be a key-value set, or an array, number and string, they storage in AutoTree memory zone and their life-cycle managed by reference count.
 */
typedef builtin AutoTree;

/*
 CH: 表示树节点的类型
 EN: Describing Tree Type
 */
typedef builtin TreeType;

/*
 CH: 表示一个用于遍历树的迭代器
 EN: Describing Tree Iterator
 */
typedef builtin Iterator;

/*
 CH: 将一个JSON字符串转换成AutoTree树
 EN: Transfer a JSON string to an AutoTree object
 json.CH: 一个JSON字符串，此函数仅读取给定的字符串并创建新的内存来存储树
 json.EN: A JSON string, this function only read specified string and allocate the tree in AutoTree memory zone
 */
AutoTree json_tree(char* json);

/*
 CH: 将一棵树转换为JSON，写入writeTo
 EN: Transfer a Tree to JSON
 tree.CH: 待转换的树
 tree.EN: Tree to transfer
 writeTo.CH: 写入JSON字符串的地址
 writeTo.EN: JSON string write to address
 writeToSize.CH: JSON字符串最大长度
 writeToSize.EN: Maxium length of writeTo
 */
size_t tree_json(AutoTree tree, char* writeTo, size_t writeToSize);

/*
 CH: 为节点降低1个引用计数
 EN: Release tree node once
 tree.CH: 操作对象
 tree.EN: Target tree
 */
void tree_release(AutoTree tree);

/*
 CH: 为节点增加1个引用计数
 EN: Retain tree node once
 tree.CH: 操作对象
 tree.EN: Target tree
 */
void tree_retain(AutoTree tree);

/*
 CH: 获取节点引用计数
 EN: Get the reference count of node
 tree.CH: 操作对象
 tree.EN: Target tree
 */
int tree_refcnt(AutoTree tree);

/*
 CH: 获取树的path处元素
 EN: Get the specified path element of the tree
 tree.CH: 操作对象
 tree.EN: Target tree
 path.CH: 路径字符串
 path.EN: Specified path
 */
AutoTree tree_path(AutoTree tree, char* path);

/*
 CH: 获取一棵空树，空树在程序中唯一，引用计数无穷大
 EN: Get an unique empty tree, it has infinite reference count
 */
AutoTree tree_null();

/*
 CH: 深拷贝一棵树
 EN: Deep copy a tree
 fromTree.CH: 被拷贝的树
 fromTree.EN: The tree to copy
 */
AutoTree tree_clone(AutoTree fromTree);

/*
 CH: [API From 3.1.2] 为类型为数组的AutoTree添加一个元素到末尾
 EN: [API From 3.1.2] Add an object to the end of tree if tree type is array
 operation.CH: 要操作的树
 operation.EN: Tree to operate
 toAdd.CH: 要添加到末尾的节点
 toAdd.EN: Node to append to the end of specified array node
 */
void tree_array_append(AutoTree operation, AutoTree toAdd);

/*
 CH: [API From 3.1.2] 为类型为数组的AutoTree删除指定位置的元素
 EN: [API From 3.1.2] Remove an object at the specified index of the array tree
 operation.CH: 要操作的树
 operation.EN: Tree to operate
 toAdd.CH: 要删除的下标
 toAdd.EN: Index to remove
 */
void tree_array_remove(AutoTree operation, int toRemove);

/*
 CH: 为一个KV节点或数组节点创建迭代器以便遍历
 EN: Create iterator for a kv node or array node to foreach
 tree.CH: 要创建迭代器的tree节点
 tree.EN: The tree to create iterator
 */
Iterator tree_iterator(AutoTree tree);

/*
 CH: 迭代器到下一项
 EN: Move iterator to next
 iterator.CH: 迭代器
 iterator.EN: The iterator
 pathNameWriteTo.CH: 要写入下一项名称的字符串地址
 pathNameWriteTo.EN: The string address to write next element name
 writeToSize.CH: 最大写入长度
 writeToSize.EN: Maxium length of pathNameWriteTo
 */
int iterator_next(Iterator &iterator, char *pathNameWriteTo, int writeToSize);

/*
 CH: 销毁迭代器
 EN: Destroy an iterator
 iterator.CH: 要销毁的迭代器
 iterator.EN: The iterator to be destroy
 */
void iterator_destroy(Iterator &iterator);

/*
 CH: 获取节点的类型
 EN: Get the type of the tree node
 tree.CH: 节点
 tree.EN: tree node
 */
TreeType tree_typeof(AutoTree tree);

/*
 CH: 如果节点是数组，获取它的长度
 EN: If the node is an array, get the length of it
 tree.CH: 节点
 tree.EN: tree node
 */
size_t tree_arraylen(AutoTree tree);

/*
 CH: 32或64位整数节点类型
 EN: 32Bit or 64Bit integer node type
 */
TreeType tree_int;

/*
 CH: 字符串节点类型
 EN: String node type
 */
TreeType tree_str;

/*
 CH: 空节点类型
 EN: Null node type
 */
TreeType tree_empty;

/*
 CH: 键值对节点类型
 EN: Key-value map node type
 */
TreeType tree_kv;

/*
 CH: 数组节点类型
 EN: Array node type
 */
TreeType tree_array;

/*
 CH: 32位或64位浮点数节点类型
 EN: 32Bit or 64Bit float node type
 */
TreeType tree_double;
