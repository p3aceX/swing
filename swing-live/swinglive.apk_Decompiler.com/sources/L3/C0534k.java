package l3;

import e1.AbstractC0367g;
import java.util.List;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: renamed from: l3.k, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0534k extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f5692a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ K f5693b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ List f5694c;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0534k(K k4, List list, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f5693b = k4;
        this.f5694c = list;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        return new C0534k(this.f5693b, this.f5694c, interfaceC0762c);
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((C0534k) create((Q3.D) obj, (InterfaceC0762c) obj2)).invokeSuspend(w3.i.f6729a);
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        int i4 = this.f5692a;
        if (i4 != 0) {
            if (i4 != 1) {
                throw new IllegalStateException("call to 'resume' before 'invoke' with coroutine");
            }
            AbstractC0367g.M(obj);
            return obj;
        }
        AbstractC0367g.M(obj);
        this.f5692a = 1;
        Object objS = K.s(this.f5693b, this.f5694c, this);
        return objS == enumC0789a ? enumC0789a : objS;
    }
}
