package T3;

import D2.v;
import y3.InterfaceC0762c;

/* JADX INFO: loaded from: classes.dex */
public final class j extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public /* synthetic */ Object f2039a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f2040b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ v f2041c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public v f2042d;
    public e e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public U3.l f2043f;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public j(v vVar, InterfaceC0762c interfaceC0762c) {
        super(interfaceC0762c);
        this.f2041c = vVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f2039a = obj;
        this.f2040b |= Integer.MIN_VALUE;
        return this.f2041c.b(null, this);
    }
}
