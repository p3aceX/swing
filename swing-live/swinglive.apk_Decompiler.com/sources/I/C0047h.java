package I;

import e1.AbstractC0367g;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: renamed from: I.h, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0047h extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public Iterator f662a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Object f663b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f664c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public /* synthetic */ Object f665d;
    public final /* synthetic */ List e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final /* synthetic */ ArrayList f666f;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0047h(List list, ArrayList arrayList, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.e = list;
        this.f666f = arrayList;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        C0047h c0047h = new C0047h(this.e, this.f666f, interfaceC0762c);
        c0047h.f665d = obj;
        return c0047h;
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((C0047h) create(obj, (InterfaceC0762c) obj2)).invokeSuspend(w3.i.f6729a);
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        Iterator it;
        List list;
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        int i4 = this.f664c;
        if (i4 == 0) {
            AbstractC0367g.M(obj);
            obj = this.f665d;
            it = this.e.iterator();
            list = this.f666f;
        } else if (i4 == 1) {
            Object obj2 = this.f663b;
            Iterator it2 = this.f662a;
            List list2 = (List) this.f665d;
            AbstractC0367g.M(obj);
            if (((Boolean) obj).booleanValue()) {
                list2.add(new C0046g(1, null));
                this.f665d = list2;
                this.f662a = it2;
                this.f663b = null;
                this.f664c = 2;
                throw null;
            }
            obj = obj2;
            it = it2;
            list = list2;
        } else {
            if (i4 != 2) {
                throw new IllegalStateException("call to 'resume' before 'invoke' with coroutine");
            }
            it = this.f662a;
            list = (List) this.f665d;
            AbstractC0367g.M(obj);
        }
        if (!it.hasNext()) {
            return obj;
        }
        if (it.next() != null) {
            throw new ClassCastException();
        }
        this.f665d = list;
        this.f662a = it;
        this.f663b = obj;
        this.f664c = 1;
        throw null;
    }
}
