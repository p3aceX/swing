package e2;

import e1.AbstractC0367g;

/* JADX INFO: renamed from: e2.I, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0377I extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public AbstractC0367g f4034a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public long f4035b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public /* synthetic */ Object f4036c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ L f4037d;
    public int e;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0377I(L l2, A3.c cVar) {
        super(cVar);
        this.f4037d = l2;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f4036c = obj;
        this.e |= Integer.MIN_VALUE;
        return this.f4037d.d(this);
    }
}
