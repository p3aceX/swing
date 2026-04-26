package e2;

import e1.AbstractC0367g;
import h2.C0413b;

/* JADX INFO: renamed from: e2.n, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0393n extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public AbstractC0367g f4165a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public String f4166b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public C0413b f4167c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public /* synthetic */ Object f4168d;
    public final /* synthetic */ r e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public int f4169f;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0393n(r rVar, A3.c cVar) {
        super(cVar);
        this.e = rVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f4168d = obj;
        this.f4169f |= Integer.MIN_VALUE;
        return this.e.i(null, this);
    }
}
