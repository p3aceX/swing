package r2;

import m1.C0553h;

/* JADX INFO: loaded from: classes.dex */
public final class d extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f6323a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f6324b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public C0553h f6325c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public Y3.a f6326d;
    public /* synthetic */ Object e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final /* synthetic */ i f6327f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public int f6328m;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public d(i iVar, A3.c cVar) {
        super(cVar);
        this.f6327f = iVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.e = obj;
        this.f6328m |= Integer.MIN_VALUE;
        return this.f6327f.d(0, null, this);
    }
}
