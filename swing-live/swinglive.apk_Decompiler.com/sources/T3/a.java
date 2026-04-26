package T3;

import y3.InterfaceC0762c;
import z0.C0779j;

/* JADX INFO: loaded from: classes.dex */
public final class a extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public U3.l f2016a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public /* synthetic */ Object f2017b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ C0779j f2018c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f2019d;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public a(C0779j c0779j, InterfaceC0762c interfaceC0762c) {
        super(interfaceC0762c);
        this.f2018c = c0779j;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f2017b = obj;
        this.f2019d |= Integer.MIN_VALUE;
        return this.f2018c.b(null, this);
    }
}
