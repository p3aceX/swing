package l3;

import android.content.Context;
import e1.AbstractC0367g;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public final class C extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f5630a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ String f5631b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ K f5632c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ boolean f5633d;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C(String str, K k4, boolean z4, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f5631b = str;
        this.f5632c = k4;
        this.f5633d = z4;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        return new C(this.f5631b, this.f5632c, this.f5633d, interfaceC0762c);
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((C) create((Q3.D) obj, (InterfaceC0762c) obj2)).invokeSuspend(w3.i.f6729a);
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        int i4 = this.f5630a;
        if (i4 == 0) {
            AbstractC0367g.M(obj);
            L.d dVar = new L.d(this.f5631b);
            Context context = this.f5632c.f5660a;
            if (context == null) {
                J3.i.g("context");
                throw null;
            }
            B.k kVarA = L.a(context);
            B b5 = new B(dVar, this.f5633d, null);
            this.f5630a = 1;
            if (kVarA.m(new L.h(b5, null), this) == enumC0789a) {
                return enumC0789a;
            }
        } else {
            if (i4 != 1) {
                throw new IllegalStateException("call to 'resume' before 'invoke' with coroutine");
            }
            AbstractC0367g.M(obj);
        }
        return w3.i.f6729a;
    }
}
