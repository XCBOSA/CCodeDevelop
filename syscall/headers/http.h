/*
 filesummary.CH: 提供一个用于发送Http请求的函数，需要先包含autotree.h
 filesummary.EN: Provide a function used to send http request, require include autotree.h first
 CH: 表示Http请求的类型
 EN: Representation the type of http request
 */
typedef builtin HttpMethod;

/*
 CH: 表示Post请求
 EN: Representation Http Post
 */
HttpMethod http_post;

/*
 CH: 表示Get请求
 EN: Representation Http Get
 */
HttpMethod http_get;

/*
 CH: 发送Http请求
 EN: Send a http request
 url.CH: 请求的URL
 url.EN: URL Address
 method.CH: 请求类型，可以是http_get或http_post
 method.EN: Request Type, can be http_get or http_post
 args.CH: 请求参数
 args.EN: Request Parameters
 header.CH: 请求附加头部
 header.EN: Additional header for request
 */
AutoTree http_send(char *url, HttpMethod method, AutoTree args, AutoTree header);
