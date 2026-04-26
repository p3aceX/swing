package io.ktor.utils.io;

import java.nio.ByteBuffer;

/* JADX INFO: loaded from: classes.dex */
public final class u extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public C0449m f5017a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public ByteBuffer f5018b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public /* synthetic */ Object f5019c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f5020d;

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f5019c = obj;
        this.f5020d |= Integer.MIN_VALUE;
        return z.d(null, null, this);
    }
}
