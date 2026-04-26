package io.ktor.utils.io;

/* JADX INFO: renamed from: io.ktor.utils.io.i, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0445i extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public C0449m f4982a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f4983b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public /* synthetic */ Object f4984c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ C0449m f4985d;
    public int e;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0445i(C0449m c0449m, A3.c cVar) {
        super(cVar);
        this.f4985d = c0449m;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f4984c = obj;
        this.e |= Integer.MIN_VALUE;
        return this.f4985d.n(this);
    }
}
