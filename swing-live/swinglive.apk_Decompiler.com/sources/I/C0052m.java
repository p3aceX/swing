package I;

import java.io.Serializable;
import java.util.Iterator;
import y3.InterfaceC0762c;

/* JADX INFO: renamed from: I.m, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0052m extends A3.j implements I3.l {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public Object f696a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Serializable f697b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public Object f698c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public Object f699d;
    public Iterator e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public int f700f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public int f701m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public final /* synthetic */ Q f702n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public final /* synthetic */ C0053n f703o;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0052m(Q q4, C0053n c0053n, InterfaceC0762c interfaceC0762c) {
        super(1, interfaceC0762c);
        this.f702n = q4;
        this.f703o = c0053n;
    }

    @Override // A3.a
    public final InterfaceC0762c create(InterfaceC0762c interfaceC0762c) {
        return new C0052m(this.f702n, this.f703o, interfaceC0762c);
    }

    @Override // I3.l
    public final Object invoke(Object obj) {
        return ((C0052m) create((InterfaceC0762c) obj)).invokeSuspend(w3.i.f6729a);
    }

    /* JADX WARN: Removed duplicated region for block: B:23:0x00a7  */
    /* JADX WARN: Removed duplicated region for block: B:30:0x00db  */
    /* JADX WARN: Removed duplicated region for block: B:34:0x00e8  */
    /* JADX WARN: Removed duplicated region for block: B:35:0x00ed  */
    /* JADX WARN: Removed duplicated region for block: B:39:0x0103  */
    @Override // A3.a
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object invokeSuspend(java.lang.Object r14) {
        /*
            Method dump skipped, instruction units count: 280
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: I.C0052m.invokeSuspend(java.lang.Object):java.lang.Object");
    }
}
