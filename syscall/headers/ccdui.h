/*
 filesummary.CH: 提供与简单UI有关的操作
 filesummary.EN: Provide easy UI operations
 keyword: type text action color colorfg colorbg align alignment spacing space radius cornerRadius borderColor borderWidth paddingTop paddingLeft paddingBottom paddingRight fontSize width height placeholder id sub image
 CH: 表示一个可以添加组件的窗口区域
 EN: Representation a window that support add components on it
 */
typedef builtin UIContainer;

/*
 CH: 表示窗口显示的方法
 EN: Description how to show a window
 */
typedef builtin UIShowType;

/*
 CH: 在支持的设备上以新系统窗口打开，否则以弹出对话框打开
 EN: Open in new OS window if system supported, or open by an alert dialog
 */
UIShowType UIShowTypeNewWindow;

/*
 CH: 在编辑器Tab上打开
 EN: Open in new editor tab
 */
UIShowType UIShowTypeEditorTab;

/*
 CH: 创建一个窗口区域
 EN: Create a window
 */
UIContainer ccd_ui_create();

/*
 CH: 将组件树附加到窗口区域，特别的，如果当前以桌面小组件形式运行代码，则不论view参数如何，使用给定的window参数渲染组件树，并且当前进程**在此函数永不返回**
 EN: Add components tree to window. Specially, If current code running in desktop widget mode, calling this method will render the widget directly and **Never Return**
 view.CH: 组件树
 view.EN: Components tree
 window.CH: 目标窗口
 window.EN: Dest Window
 */
void ccd_ui_attach(UIContainer view, AutoTree window);

/*
 CH: 展示窗口
 EN: Display the window
 window.CH: 目标窗口
 window.EN: Dest Window
 type.CH: 窗口显示方式
 type.EN: The method to show a window
 */
void ccd_ui_show(UIContainer window, UIShowType type);

/*
 CH: 关闭窗口
 EN: Dismiss the window
 window.CH: 目标窗口
 window.EN: Dest Window
 */
void ccd_ui_close(UIContainer window);

/*
 CH: 销毁窗口
 EN: Destroy the window
 window.CH: 目标窗口
 window.EN: Dest Window
 */
void ccd_ui_destroy(UIContainer window);

/*
 CH: 以先序递归向下查找第一个id字段为给定值的节点
 EN: Search recursively, return the first node where id equals to given *id*
 */
AutoTree ccd_ui_id(AutoTree, char *id);

/*
 CH: 将程序控制权移交给事件分发循环，从而驱动事件接收。注意：此函数需要且必须在程序末尾调用，它在窗口项目结束前永不返回，函数后边不应该有代码。  \n`return ccd_ui_start();`
 EN: Hands over program control to the event dispatch loop, which drives event reception. Note: This function needs be called at the end of the program, it never returns until the windowed project ends, there should be no code after the function.  \n`return ccd_ui_start();`
 */
Never ccd_ui_start();
