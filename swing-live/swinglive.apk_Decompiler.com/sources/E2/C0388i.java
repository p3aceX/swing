package e2;

import e1.AbstractC0367g;
import i2.C0421a;
import i2.C0423c;

/* JADX INFO: renamed from: e2.i, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0388i extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public C0421a f4130a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public AbstractC0367g f4131b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public Y3.a f4132c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public C0423c f4133d;
    public int e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public int f4134f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public /* synthetic */ Object f4135m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public final /* synthetic */ r f4136n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public int f4137o;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0388i(r rVar, A3.c cVar) {
        super(cVar);
        this.f4136n = rVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f4135m = obj;
        this.f4137o |= Integer.MIN_VALUE;
        return this.f4136n.n(null, null, this);
    }
}
