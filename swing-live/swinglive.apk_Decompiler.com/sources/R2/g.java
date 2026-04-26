package r2;

import m1.C0553h;

/* JADX INFO: loaded from: classes.dex */
public final class g extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public C0553h f6342a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Y3.a f6343b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f6344c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public /* synthetic */ Object f6345d;
    public final /* synthetic */ i e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public int f6346f;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public g(i iVar, A3.c cVar) {
        super(cVar);
        this.e = iVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f6345d = obj;
        this.f6346f |= Integer.MIN_VALUE;
        return this.e.g(null, this);
    }
}
