package l3;

import I.C0059u;
import android.net.NetworkCapabilities;
import java.util.ArrayList;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: renamed from: l3.A, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0523A implements T3.d {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public Object f5626a;

    public /* synthetic */ C0523A(Object obj) {
        this.f5626a = obj;
    }

    public static ArrayList c(NetworkCapabilities networkCapabilities) {
        ArrayList arrayList = new ArrayList();
        if (networkCapabilities == null || !networkCapabilities.hasCapability(12)) {
            arrayList.add("none");
            return arrayList;
        }
        if (networkCapabilities.hasTransport(1) || networkCapabilities.hasTransport(5)) {
            arrayList.add("wifi");
        }
        if (networkCapabilities.hasTransport(3)) {
            arrayList.add("ethernet");
        }
        if (networkCapabilities.hasTransport(4)) {
            arrayList.add("vpn");
        }
        if (networkCapabilities.hasTransport(0)) {
            arrayList.add("mobile");
        }
        if (networkCapabilities.hasTransport(2)) {
            arrayList.add("bluetooth");
        }
        if (arrayList.isEmpty() && networkCapabilities.hasCapability(12)) {
            arrayList.add("other");
        }
        if (arrayList.isEmpty()) {
            arrayList.add("none");
        }
        return arrayList;
    }

    public int a(int i4, int i5) {
        int i6 = i4 / 8;
        int i7 = i4 % 8;
        int i8 = 0;
        for (int i9 = 0; i9 < i5; i9++) {
            int i10 = (i7 + i9) % 8;
            i8 = (i8 << 1) | ((((byte[]) this.f5626a)[(i10 < i7 ? 1 : 0) + i6] >>> (7 - i10)) & 1);
        }
        return i8;
    }

    @Override // T3.d
    public Object b(T3.e eVar, InterfaceC0762c interfaceC0762c) {
        Object objB = ((T3.d) this.f5626a).b(new C0059u(eVar, 1), interfaceC0762c);
        return objB == EnumC0789a.f6999a ? objB : w3.i.f6729a;
    }
}
