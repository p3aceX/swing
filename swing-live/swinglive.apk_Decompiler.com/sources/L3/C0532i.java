package l3;

import android.content.Context;
import e1.AbstractC0367g;
import java.util.List;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: renamed from: l3.i, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0532i extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f5686a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ K f5687b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ List f5688c;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0532i(K k4, List list, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f5687b = k4;
        this.f5688c = list;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        return new C0532i(this.f5687b, this.f5688c, interfaceC0762c);
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((C0532i) create((Q3.D) obj, (InterfaceC0762c) obj2)).invokeSuspend(w3.i.f6729a);
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        int i4 = this.f5686a;
        if (i4 != 0) {
            if (i4 != 1) {
                throw new IllegalStateException("call to 'resume' before 'invoke' with coroutine");
            }
            AbstractC0367g.M(obj);
            return obj;
        }
        AbstractC0367g.M(obj);
        Context context = this.f5687b.f5660a;
        if (context == null) {
            J3.i.g("context");
            throw null;
        }
        B.k kVarA = L.a(context);
        C0531h c0531h = new C0531h(this.f5688c, null);
        this.f5686a = 1;
        Object objM = kVarA.m(new L.h(c0531h, null), this);
        return objM == enumC0789a ? enumC0789a : objM;
    }
}
