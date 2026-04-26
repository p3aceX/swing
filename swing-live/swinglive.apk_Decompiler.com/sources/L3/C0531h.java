package l3;

import e1.AbstractC0367g;
import java.util.List;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: renamed from: l3.h, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0531h extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public /* synthetic */ Object f5684a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ List f5685b;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0531h(List list, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f5685b = list;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        C0531h c0531h = new C0531h(this.f5685b, interfaceC0762c);
        c0531h.f5684a = obj;
        return c0531h;
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        C0531h c0531h = (C0531h) create((L.b) obj, (InterfaceC0762c) obj2);
        w3.i iVar = w3.i.f6729a;
        c0531h.invokeSuspend(iVar);
        return iVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        AbstractC0367g.M(obj);
        L.b bVar = (L.b) this.f5684a;
        List<String> list = this.f5685b;
        if (list != null) {
            for (String str : list) {
                J3.i.e(str, "name");
                L.d dVar = new L.d(str);
                bVar.b();
                bVar.f861a.remove(dVar);
            }
        } else {
            bVar.b();
            bVar.f861a.clear();
        }
        return w3.i.f6729a;
    }
}
