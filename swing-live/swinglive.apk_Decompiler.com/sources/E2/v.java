package e2;

import e1.AbstractC0367g;

/* JADX INFO: loaded from: classes.dex */
public final class v extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public AbstractC0367g f4217a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public byte[] f4218b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public /* synthetic */ Object f4219c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ D2.A f4220d;
    public int e;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public v(D2.A a5, A3.c cVar) {
        super(cVar);
        this.f4220d = a5;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f4219c = obj;
        this.e |= Integer.MIN_VALUE;
        return this.f4220d.e(null, this);
    }
}
