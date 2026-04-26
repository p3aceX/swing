package r2;

import m1.C0553h;

/* JADX INFO: loaded from: classes.dex */
public final class f extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public C0553h f6336a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public u2.c f6337b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public Y3.a f6338c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f6339d;
    public /* synthetic */ Object e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final /* synthetic */ i f6340f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public int f6341m;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public f(i iVar, A3.c cVar) {
        super(cVar);
        this.f6340f = iVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.e = obj;
        this.f6341m |= Integer.MIN_VALUE;
        return this.f6340f.f(null, null, this);
    }
}
