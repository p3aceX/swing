package e2;

import e1.AbstractC0367g;
import j2.C0463a;

/* JADX INFO: renamed from: e2.p, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0395p extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public AbstractC0367g f4174a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public C0463a f4175b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public /* synthetic */ Object f4176c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ r f4177d;
    public int e;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0395p(r rVar, A3.c cVar) {
        super(cVar);
        this.f4177d = rVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f4176c = obj;
        this.e |= Integer.MIN_VALUE;
        return this.f4177d.m(null, this);
    }
}
