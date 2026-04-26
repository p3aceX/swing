package T3;

import D2.v;
import l3.C0536m;
import y3.InterfaceC0762c;

/* JADX INFO: loaded from: classes.dex */
public final class m extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public /* synthetic */ Object f2052a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f2053b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ v f2054c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public C0536m f2055d;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public m(v vVar, InterfaceC0762c interfaceC0762c) {
        super(interfaceC0762c);
        this.f2054c = vVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f2052a = obj;
        this.f2053b |= Integer.MIN_VALUE;
        return this.f2054c.b(null, this);
    }
}
