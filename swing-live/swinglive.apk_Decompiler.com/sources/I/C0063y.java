package I;

import Q3.C0146s;

/* JADX INFO: renamed from: I.y, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0063y extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public Object f739a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Q f740b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public C0146s f741c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public /* synthetic */ Object f742d;
    public final /* synthetic */ Q e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public int f743f;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0063y(Q q4, A3.c cVar) {
        super(cVar);
        this.e = q4;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f742d = obj;
        this.f743f |= Integer.MIN_VALUE;
        return Q.b(this.e, null, this);
    }
}
