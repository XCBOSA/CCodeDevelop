int GenericCCDScanf(int file, char *format, void *scanfArg[8], int scanfArgCount, ASTParser *Parser) {
    int parseCount = 0;
    char *fmt = malloc(strlen(format) + 1), *fmtbkup = fmt;
    strcpy(fmt, format);
    int scanfArgIdx = 0;
    char tmpBuf[1024];
    int  tmpBuf_idx = 0;
    int fgHasNonSpace = 0, fgLongLong = 0;
    char tch, ch = *fmt;
#define ResetTmpBuf memset(tmpBuf, 0, 1024); tmpBuf_idx = 0;
#define SkipFileToChar(chr) { while (1) { tch = clgetch(file, Parser); if (tch == 0) break; if (tch == chr) { clungetch(file, tch, Parser); break; } } }
#define SkipFileToCharRange(eom, eol) { while (1) { tch = clgetch(file, Parser); if (tch == 0) break; if (tch >= eom && tch <= eol) { clungetch(file, tch, Parser); break; } } }
#define IsNumber(__ch) (__ch >= '0' && __ch <= '9')
#define DoClean { free(fmtbkup); }
    while (ch != 0) {
        ch = *fmt++;
        if (ch == '\0') break;
        if (ch == '%') {
            char nxtCh = *fmt++;
            switch (nxtCh) {
                case 'd':
                case 'f':
                case 'F':
                case 'a':
                case 'A':
                case 'e':
                case 'E':
                case 'g':
                case 'G':
                    ResetTmpBuf;
                    char numchr = 0;
                    while (1) {
                        tch = clgetch(file, Parser);
                        if (tch == 0) break;
                        if (IsNumber(tch)) {
                            clungetch(file, tch, Parser);
                            break;
                        }
                        if (tch == '+' || tch == '-') {
                            numchr = tch;
                            break;
                        }
                        if (tch == ' ' || tch == '\t' || tch == '\n') continue;
                        clungetch(file, tch, Parser);
                        return parseCount;
                    }
                    if (numchr != 0) tmpBuf[tmpBuf_idx++] = numchr;
                    int fptc = 0;
                    while (1) {
                        tch = clgetch(file, Parser);
                        if (tch == 0) break;
                        if (IsNumber(tch) || (tch == '.' && nxtCh == 'f' && fptc == 0)) {
                            tmpBuf[tmpBuf_idx++] = tch;
                            if (tch == '.') fptc++;
                        }
                        else {
                            clungetch(file, tch, Parser);
                            break;
                        }
                    }
                    if (scanfArgIdx < scanfArgCount) {
                        if (nxtCh == 'd') {
                            if (fgLongLong) {
                                *(long long *)scanfArg[scanfArgIdx++] = atoll(tmpBuf);
                                fgLongLong = 0;
                            } else {
                                *(int *)scanfArg[scanfArgIdx++] = atoi(tmpBuf);
                            }
                        }
                        else if (nxtCh == 'F' || nxtCh == 'f' || nxtCh == 'a' || nxtCh == 'A' || nxtCh == 'e' || nxtCh == 'E' || nxtCh == 'g' || nxtCh == 'G') {
                            if (fgLongLong) {
                                *(double *)scanfArg[scanfArgIdx++] = atof(tmpBuf);
                                fgLongLong = 0;
                            } else {
                                char *fpptr = (char *)scanfArg[scanfArgIdx++];
                                double realValt = atof(tmpBuf);
                                char *fpr = (char *)&realValt;
                                for (int i = 0; i < 8; i++) {
                                    fpptr[i] = fpr[i];
                                }
                            }
                        }
                        parseCount++;
                    } else {
                        DoClean;
                        return parseCount;
                    }
                    break;
                case 'c':
                    tch = clgetch(file, Parser);
                    if (tch == 0) {
                        DoClean;
                        return parseCount;
                    }
                    if (scanfArgIdx < scanfArgCount) {
                        *(char *)scanfArg[scanfArgIdx++] = tch;
                    } else {
                        DoClean;
                        return parseCount;
                    }
                    break;
                case 's':
                    fgHasNonSpace = 0;
                    if (scanfArgIdx < scanfArgCount) {
                        char *pstr = (char *)scanfArg[scanfArgIdx++];
                        while (1) {
                            tch = clgetch(file, Parser);
                            if (tch == 0) break;
                            if (isspace(tch)) {
                                if (fgHasNonSpace) break;
                            } else fgHasNonSpace = 1;
                            *(pstr++) = tch;
                        }
                        *(pstr++) = 0;
                    } else {
                        DoClean;
                        return parseCount;
                    }
                    break;
                case '%':
                    SkipFileToChar('%');
                    clgetch(file, Parser);
                    break;
                case 'l':
                    while (1) {
                        ch = *fmt++;
                        if (ch == '\0') {
                            DoClean;
                            return parseCount;
                        }
                        if (ch != 'l') break;
                    }
                    fgLongLong = 1;
                    fmt -= 2;
                    *fmt = '%';
                    continue;
                default:
                    break;
            }
        } else {
            while (1) {
                tch = clgetch(file, Parser);
                if (tch == 0) break;
                if ((isspace(ch) && isspace(tch)) || tch == ch) break;
            }
        }
    }
    DoClean;
    return parseCount;
}
