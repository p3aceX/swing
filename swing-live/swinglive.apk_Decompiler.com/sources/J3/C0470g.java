package j3;

import O2.q;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.List;

/* JADX INFO: renamed from: j3.g, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0470g extends q {

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final C0470g f5243d = new C0470g();

    @Override // O2.q
    public final Object f(byte b5, ByteBuffer byteBuffer) {
        switch (b5) {
            case -127:
                Object objE = e(byteBuffer);
                if (objE == null) {
                    return null;
                }
                return EnumC0471h.values()[((Long) objE).intValue()];
            case -126:
                ArrayList arrayList = (ArrayList) e(byteBuffer);
                C0469f c0469f = new C0469f();
                List list = (List) arrayList.get(0);
                if (list == null) {
                    throw new IllegalStateException("Nonnull field \"scopes\" is null.");
                }
                c0469f.f5237a = list;
                EnumC0471h enumC0471h = (EnumC0471h) arrayList.get(1);
                if (enumC0471h == null) {
                    throw new IllegalStateException("Nonnull field \"signInType\" is null.");
                }
                c0469f.f5238b = enumC0471h;
                c0469f.f5239c = (String) arrayList.get(2);
                c0469f.f5240d = (String) arrayList.get(3);
                c0469f.e = (String) arrayList.get(4);
                Boolean bool = (Boolean) arrayList.get(5);
                if (bool == null) {
                    throw new IllegalStateException("Nonnull field \"forceCodeForRefreshToken\" is null.");
                }
                c0469f.f5241f = bool;
                c0469f.f5242g = (String) arrayList.get(6);
                return c0469f;
            case -125:
                ArrayList arrayList2 = (ArrayList) e(byteBuffer);
                C0472i c0472i = new C0472i();
                c0472i.f5246a = (String) arrayList2.get(0);
                String str = (String) arrayList2.get(1);
                if (str == null) {
                    throw new IllegalStateException("Nonnull field \"email\" is null.");
                }
                c0472i.f5247b = str;
                String str2 = (String) arrayList2.get(2);
                if (str2 == null) {
                    throw new IllegalStateException("Nonnull field \"id\" is null.");
                }
                c0472i.f5248c = str2;
                c0472i.f5249d = (String) arrayList2.get(3);
                c0472i.e = (String) arrayList2.get(4);
                c0472i.f5250f = (String) arrayList2.get(5);
                return c0472i;
            default:
                return super.f(b5, byteBuffer);
        }
    }

    @Override // O2.q
    public final void k(F3.a aVar, Object obj) {
        if (obj instanceof EnumC0471h) {
            aVar.write(129);
            k(aVar, obj == null ? null : Integer.valueOf(((EnumC0471h) obj).f5245a));
            return;
        }
        if (obj instanceof C0469f) {
            aVar.write(130);
            C0469f c0469f = (C0469f) obj;
            c0469f.getClass();
            ArrayList arrayList = new ArrayList(7);
            arrayList.add(c0469f.f5237a);
            arrayList.add(c0469f.f5238b);
            arrayList.add(c0469f.f5239c);
            arrayList.add(c0469f.f5240d);
            arrayList.add(c0469f.e);
            arrayList.add(c0469f.f5241f);
            arrayList.add(c0469f.f5242g);
            k(aVar, arrayList);
            return;
        }
        if (!(obj instanceof C0472i)) {
            super.k(aVar, obj);
            return;
        }
        aVar.write(131);
        C0472i c0472i = (C0472i) obj;
        c0472i.getClass();
        ArrayList arrayList2 = new ArrayList(6);
        arrayList2.add(c0472i.f5246a);
        arrayList2.add(c0472i.f5247b);
        arrayList2.add(c0472i.f5248c);
        arrayList2.add(c0472i.f5249d);
        arrayList2.add(c0472i.e);
        arrayList2.add(c0472i.f5250f);
        k(aVar, arrayList2);
    }
}
