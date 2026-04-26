package r2;

import m1.C0553h;
import n2.C0560c;

/* JADX INFO: loaded from: classes.dex */
public final class e extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public C0560c f6329a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public C0553h f6330b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public Y3.a f6331c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public s2.b f6332d;
    public int e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public /* synthetic */ Object f6333f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final /* synthetic */ i f6334m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public int f6335n;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public e(i iVar, A3.c cVar) {
        super(cVar);
        this.f6334m = iVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f6333f = obj;
        this.f6335n |= Integer.MIN_VALUE;
        return this.f6334m.e(null, null, this);
    }
}
