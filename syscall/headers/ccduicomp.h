/*
 filesummary.CH: 提供默认的基础UI元素模版
 filesummary.EN: Provide default UI item template
 */
#ifndef CCDUICOMP_H
#define CCDUICOMP_H

#include "string.h"

/*
 CH: UI事件（action字段）遵循的函数定义
 EN: UI Action Confirm Block
 */
typedef void (*Action)(AutoTree, AutoTree);

/*
 CH: 元素: 展示文本
 EN: UI Item: Display given text
 */
AutoTree text(char *text) {
    AutoTree tree = @{
        type: "label",
        text: text
    };
    return tree;
}

/*
 CH: 元素: 展示文本
 EN: UI Item: Display given text
 */
AutoTree label(char *text) {
    AutoTree tree = @{
        type: "label",
        text: text
    };
    return tree;
}

/*
 CH: 元素: 展示整数数字
 EN: UI Item: Display given integer
 */
AutoTree labeli(long n) {
    AutoTree tree = @{
        type: "label",
        text: n
    };
    return tree;
}

/*
 CH: 元素: 展示浮点数
 EN: UI Item: Display given double
 */
AutoTree labelf(double n) {
    AutoTree tree = @{
        type: "label",
        text: n
    };
    return tree;
}

/*
 CH: 元素: 展示输入框
 EN: UI Item: Display Input Field
 */
AutoTree input(char *placeHolder) {
    AutoTree tree = @{
        type: "input",
        placeholder: placeHolder,
        text: ""
    };
    return tree;
}

/*
 CH: 元素: 展示输入框，当输入内容改变时触发事件
 EN: UI Item: Display Input Field, When text changed call action
 */
AutoTree inputa(char *placeHolder, Action action) {
    AutoTree tree = @{
        type: "input",
        placeholder: placeHolder,
        text: "",
        action: action
    };
    return tree;
}

/*
 CH: 元素: 展示一个可点击的按钮，在用户点击时action函数指针被调用
 EN: UI Item: Display a button, action pointer will call on click time
 */
AutoTree button(char *text, Action action) {
    AutoTree tree = @{
        type: "button",
        text: text,
        action: action
    };
    return tree;
}

/*
 CH: 元素: 填充X或Y方向剩余的空间，如同方向有多个则平分剩余空间
 EN: UI Item: Fill the x or y axis space
 */
AutoTree spacer() {
    AutoTree tree = @{
        type: "spacer",
        space: 0
    };
    return tree;
}

/*
 CH: 元素: 填充X或Y方向剩余的空间，并给定一个最少填充大小（当多个同方向space出现时计算比例）
 EN: UI Item: Fill the x or y axis space, and given a minium fill size if more than one spacer in same direction
 */
AutoTree spacerm(double minSpace) {
    AutoTree tree = @{
        type: "spacer",
        space: minSpace
    };
    return tree;
}

/*
 CH: 元素: 按竖直方向排列子元素的容器
 EN: UI Item: A container that arrange sub items in y-axis
 */
AutoTree vstack(AutoTree mutating) {
    AutoTree tree = @{
        type: "vstack"
        sub: mutating
    };
    return tree;
}

/*
 CH: 元素: 按水平方向排列子元素的容器
 EN: UI Item: A container that arrange sub items in x-axis
 */
AutoTree hstack(AutoTree mutating) {
    AutoTree tree = @{
        type: "hstack"
        sub: mutating
    };
    return tree;
}

/*
 CH: 元素: 按Z方向排列子元素的容器
 EN: UI Item: A container that arrange sub items in z-axis
 */
AutoTree zstack(AutoTree mutating) {
    AutoTree tree = @{
        type: "zstack"
        sub: mutating
    };
    return tree;
}

/*
 CH: 元素: 按竖直方向排列列表的容器
 EN: UI Item: A container list that arrange sub items in y-axis
 */
AutoTree list(AutoTree mutating) {
    AutoTree tree = @{
        type: "list"
        sub: mutating
    };
    return tree;
}

/*
 CH: 组件: 属于元素且属于组件的容器，在Action函数中root参数为触发该Action的第一个根component元素
 EN: UI Component: The container that belongs to item and belongs to the component. In the Action function, the root parameter is the first root component element that triggers the Action.
 */
AutoTree component(AutoTree mutating) {
    AutoTree tree = @{
        type: "component"
        sub: mutating
    };
    return tree;
}

/*
 CH: 元素: 空白元素
 EN: UI Item: Blank Item
 */
AutoTree view(AutoTree mutating) {
    AutoTree tree = @{
        type: "view"
        sub: mutating
    };
    return tree;
}

#endif

