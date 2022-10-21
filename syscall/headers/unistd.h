/*
 filesummary.CH: 提供部分POSIX系统函数，例如sleep
 filesummary.EN: Provide some POSIX system functions, such as sleep
 CH: 暂停指定的秒数
 EN: Suspend current thread for given seconds
 */
void sleep(unsigned int);

/*
 CH: 暂停指定的微秒数
 EN: Suspend current thread for given mseconds
 */
void usleep(unsigned int);

/*
 CH: system("pause")
 EN: system("pause")
 */
int pause();
