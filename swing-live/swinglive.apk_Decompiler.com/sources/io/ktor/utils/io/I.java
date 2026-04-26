package io.ktor.utils.io;

import java.util.Iterator;

/* JADX INFO: loaded from: classes.dex */
public final class I extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public Iterator f4957a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f4958b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public /* synthetic */ Object f4959c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ J f4960d;
    public int e;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public I(J j4, A3.c cVar) {
        super(cVar);
        this.f4960d = j4;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f4959c = obj;
        this.e |= Integer.MIN_VALUE;
        return this.f4960d.b(this);
    }
}
