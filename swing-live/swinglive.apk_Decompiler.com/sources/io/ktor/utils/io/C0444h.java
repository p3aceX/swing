package io.ktor.utils.io;

/* JADX INFO: renamed from: io.ktor.utils.io.h, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0444h extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f4977a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f4978b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public C0449m f4979c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public /* synthetic */ Object f4980d;
    public final /* synthetic */ C0449m e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public int f4981f;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0444h(C0449m c0449m, A3.c cVar) {
        super(cVar);
        this.e = c0449m;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f4980d = obj;
        this.f4981f |= Integer.MIN_VALUE;
        return this.e.a(0, this);
    }
}
