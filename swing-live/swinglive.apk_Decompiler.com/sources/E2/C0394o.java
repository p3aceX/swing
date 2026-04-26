package e2;

import e1.AbstractC0367g;
import h2.C0413b;

/* JADX INFO: renamed from: e2.o, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0394o extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public AbstractC0367g f4170a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public C0413b f4171b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public /* synthetic */ Object f4172c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ r f4173d;
    public int e;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0394o(r rVar, A3.c cVar) {
        super(cVar);
        this.f4173d = rVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f4172c = obj;
        this.e |= Integer.MIN_VALUE;
        return this.f4173d.k(null, null, this);
    }
}
