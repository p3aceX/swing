package r2;

import m1.C0553h;

/* JADX INFO: loaded from: classes.dex */
public final class h extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public C0553h f6347a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Y3.a f6348b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f6349c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public /* synthetic */ Object f6350d;
    public final /* synthetic */ i e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public int f6351f;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public h(i iVar, A3.c cVar) {
        super(cVar);
        this.e = iVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f6350d = obj;
        this.f6351f |= Integer.MIN_VALUE;
        return this.e.h(null, this);
    }
}
