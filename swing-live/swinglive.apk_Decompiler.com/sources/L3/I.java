package l3;

import android.content.Context;
import e1.AbstractC0367g;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public final class I extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f5652a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ String f5653b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ K f5654c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ long f5655d;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public I(String str, K k4, long j4, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f5653b = str;
        this.f5654c = k4;
        this.f5655d = j4;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        return new I(this.f5653b, this.f5654c, this.f5655d, interfaceC0762c);
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((I) create((Q3.D) obj, (InterfaceC0762c) obj2)).invokeSuspend(w3.i.f6729a);
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        int i4 = this.f5652a;
        if (i4 == 0) {
            AbstractC0367g.M(obj);
            L.d dVar = new L.d(this.f5653b);
            Context context = this.f5654c.f5660a;
            if (context == null) {
                J3.i.g("context");
                throw null;
            }
            B.k kVarA = L.a(context);
            H h4 = new H(dVar, this.f5655d, null);
            this.f5652a = 1;
            if (kVarA.m(new L.h(h4, null), this) == enumC0789a) {
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
