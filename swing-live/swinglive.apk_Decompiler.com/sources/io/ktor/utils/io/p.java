package io.ktor.utils.io;

/* JADX INFO: loaded from: classes.dex */
public final class p extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public Z3.a f4998a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public /* synthetic */ Object f4999b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f5000c;

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f4999b = obj;
        this.f5000c |= Integer.MIN_VALUE;
        return z.e(null, this);
    }
}
