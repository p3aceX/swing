package com.google.android.gms.internal.base;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.ThreadFactory;

/* JADX INFO: loaded from: classes.dex */
public interface zam {
    ExecutorService zaa(ThreadFactory threadFactory, int i4);

    ExecutorService zab(int i4, int i5);

    ExecutorService zac(int i4, ThreadFactory threadFactory, int i5);
}
