package e2;

import e1.AbstractC0367g;
import h2.C0413b;

/* JADX INFO: renamed from: e2.m, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0392m extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public AbstractC0367g f4159a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public C0413b f4160b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public C0413b f4161c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public C0413b f4162d;
    public /* synthetic */ Object e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final /* synthetic */ r f4163f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public int f4164m;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0392m(r rVar, A3.c cVar) {
        super(cVar);
        this.f4163f = rVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.e = obj;
        this.f4164m |= Integer.MIN_VALUE;
        return this.f4163f.c(null, this);
    }
}
