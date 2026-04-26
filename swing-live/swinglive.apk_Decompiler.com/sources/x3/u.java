package x3;

import java.util.Iterator;
import y3.InterfaceC0762c;

/* JADX INFO: loaded from: classes.dex */
public final class u extends A3.i implements I3.p {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Object f6791b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public Iterator f6792c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f6793d;
    public int e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public int f6794f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public /* synthetic */ Object f6795m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public final /* synthetic */ int f6796n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public final /* synthetic */ int f6797o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public final /* synthetic */ Iterator f6798p;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public u(int i4, int i5, Iterator it, InterfaceC0762c interfaceC0762c) {
        super(interfaceC0762c);
        this.f6796n = i4;
        this.f6797o = i5;
        this.f6798p = it;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        u uVar = new u(this.f6796n, this.f6797o, this.f6798p, interfaceC0762c);
        uVar.f6795m = obj;
        return uVar;
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((u) create((O3.d) obj, (InterfaceC0762c) obj2)).invokeSuspend(w3.i.f6729a);
    }

    /* JADX WARN: Removed duplicated region for block: B:26:0x008a  */
    /* JADX WARN: Removed duplicated region for block: B:35:0x00b4  */
    /* JADX WARN: Removed duplicated region for block: B:40:0x00da  */
    /* JADX WARN: Removed duplicated region for block: B:62:0x014f  */
    /* JADX WARN: Removed duplicated region for block: B:64:0x0167  */
    @Override // A3.a
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object invokeSuspend(java.lang.Object r19) {
        /*
            Method dump skipped, instruction units count: 387
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: x3.u.invokeSuspend(java.lang.Object):java.lang.Object");
    }
}
