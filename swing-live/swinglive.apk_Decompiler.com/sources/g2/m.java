package g2;

import X.N;
import e1.AbstractC0367g;

/* JADX INFO: loaded from: classes.dex */
public final class m extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public AbstractC0367g f4385a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public com.google.android.gms.common.internal.r f4386b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public o f4387c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public byte[] f4388d;
    public int e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public /* synthetic */ Object f4389f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final /* synthetic */ N f4390m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public int f4391n;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public m(N n4, A3.c cVar) {
        super(cVar);
        this.f4390m = n4;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f4389f = obj;
        this.f4391n |= Integer.MIN_VALUE;
        return this.f4390m.j(0, this, null, null);
    }
}
