package L;

import I.C0042c;
import I.o0;
import J3.i;
import K.j;
import K.k;
import androidx.datastore.preferences.protobuf.AbstractC0209u;
import androidx.datastore.preferences.protobuf.AbstractC0211w;
import androidx.datastore.preferences.protobuf.C0196g;
import androidx.datastore.preferences.protobuf.C0200k;
import androidx.datastore.preferences.protobuf.C0213y;
import androidx.datastore.preferences.protobuf.InterfaceC0210v;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Set;
import java.util.logging.Logger;
import x3.AbstractC0728h;

/* JADX INFO: loaded from: classes.dex */
public final class g {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final g f868a = new g();

    public final b a(FileInputStream fileInputStream) throws C0042c {
        byte[] bArr;
        try {
            K.f fVarO = K.f.o(fileInputStream);
            b bVar = new b(false);
            e[] eVarArr = (e[]) Arrays.copyOf(new e[0], 0);
            i.e(eVarArr, "pairs");
            bVar.b();
            if (eVarArr.length > 0) {
                e eVar = eVarArr[0];
                throw null;
            }
            Map mapM = fVarO.m();
            i.d(mapM, "preferencesProto.preferencesMap");
            for (Map.Entry entry : mapM.entrySet()) {
                String str = (String) entry.getKey();
                k kVar = (k) entry.getValue();
                i.d(str, "name");
                i.d(kVar, "value");
                int iC = kVar.C();
                switch (iC == 0 ? -1 : f.f867a[j.b(iC)]) {
                    case -1:
                        throw new C0042c("Value case is null.", null);
                    case 0:
                    default:
                        throw new A0.b();
                    case 1:
                        bVar.d(new d(str), Boolean.valueOf(kVar.t()));
                        break;
                    case 2:
                        bVar.d(new d(str), Float.valueOf(kVar.x()));
                        break;
                    case 3:
                        bVar.d(new d(str), Double.valueOf(kVar.w()));
                        break;
                    case 4:
                        bVar.d(new d(str), Integer.valueOf(kVar.y()));
                        break;
                    case 5:
                        bVar.d(new d(str), Long.valueOf(kVar.z()));
                        break;
                    case k.STRING_SET_FIELD_NUMBER /* 6 */:
                        d dVar = new d(str);
                        String strA = kVar.A();
                        i.d(strA, "value.string");
                        bVar.d(dVar, strA);
                        break;
                    case k.DOUBLE_FIELD_NUMBER /* 7 */:
                        d dVar2 = new d(str);
                        InterfaceC0210v interfaceC0210vN = kVar.B().n();
                        i.d(interfaceC0210vN, "value.stringSet.stringsList");
                        bVar.d(dVar2, AbstractC0728h.m0(interfaceC0210vN));
                        break;
                    case k.BYTES_FIELD_NUMBER /* 8 */:
                        d dVar3 = new d(str);
                        C0196g c0196gU = kVar.u();
                        int size = c0196gU.size();
                        if (size == 0) {
                            bArr = AbstractC0211w.f3036b;
                        } else {
                            byte[] bArr2 = new byte[size];
                            c0196gU.i(bArr2, size);
                            bArr = bArr2;
                        }
                        i.d(bArr, "value.bytes.toByteArray()");
                        bVar.d(dVar3, bArr);
                        break;
                    case 9:
                        throw new C0042c("Value not set.", null);
                }
            }
            return new b(new LinkedHashMap(bVar.a()), true);
        } catch (C0213y e) {
            throw new C0042c("Unable to parse preferences proto.", e);
        }
    }

    public final void b(Object obj, o0 o0Var) throws IOException {
        AbstractC0209u abstractC0209uA;
        Map mapA = ((b) obj).a();
        K.d dVarN = K.f.n();
        for (Map.Entry entry : mapA.entrySet()) {
            d dVar = (d) entry.getKey();
            Object value = entry.getValue();
            String str = dVar.f866a;
            if (value instanceof Boolean) {
                K.i iVarD = k.D();
                boolean zBooleanValue = ((Boolean) value).booleanValue();
                iVarD.c();
                k.q((k) iVarD.f3034b, zBooleanValue);
                abstractC0209uA = iVarD.a();
            } else if (value instanceof Float) {
                K.i iVarD2 = k.D();
                float fFloatValue = ((Number) value).floatValue();
                iVarD2.c();
                k.r((k) iVarD2.f3034b, fFloatValue);
                abstractC0209uA = iVarD2.a();
            } else if (value instanceof Double) {
                K.i iVarD3 = k.D();
                double dDoubleValue = ((Number) value).doubleValue();
                iVarD3.c();
                k.o((k) iVarD3.f3034b, dDoubleValue);
                abstractC0209uA = iVarD3.a();
            } else if (value instanceof Integer) {
                K.i iVarD4 = k.D();
                int iIntValue = ((Number) value).intValue();
                iVarD4.c();
                k.s((k) iVarD4.f3034b, iIntValue);
                abstractC0209uA = iVarD4.a();
            } else if (value instanceof Long) {
                K.i iVarD5 = k.D();
                long jLongValue = ((Number) value).longValue();
                iVarD5.c();
                k.l((k) iVarD5.f3034b, jLongValue);
                abstractC0209uA = iVarD5.a();
            } else if (value instanceof String) {
                K.i iVarD6 = k.D();
                iVarD6.c();
                k.m((k) iVarD6.f3034b, (String) value);
                abstractC0209uA = iVarD6.a();
            } else if (value instanceof Set) {
                K.i iVarD7 = k.D();
                K.g gVarO = K.h.o();
                i.c(value, "null cannot be cast to non-null type kotlin.collections.Set<kotlin.String>");
                gVarO.c();
                K.h.l((K.h) gVarO.f3034b, (Set) value);
                iVarD7.c();
                k.n((k) iVarD7.f3034b, (K.h) gVarO.a());
                abstractC0209uA = iVarD7.a();
            } else {
                if (!(value instanceof byte[])) {
                    throw new IllegalStateException("PreferencesSerializer does not support type: ".concat(value.getClass().getName()));
                }
                K.i iVarD8 = k.D();
                byte[] bArr = (byte[]) value;
                C0196g c0196g = C0196g.f2968c;
                C0196g c0196gH = C0196g.h(bArr, 0, bArr.length);
                iVarD8.c();
                k.p((k) iVarD8.f3034b, c0196gH);
                abstractC0209uA = iVarD8.a();
            }
            dVarN.getClass();
            str.getClass();
            dVarN.c();
            K.f.l((K.f) dVarN.f3034b).put(str, (k) abstractC0209uA);
        }
        K.f fVar = (K.f) dVarN.a();
        int iA = fVar.a(null);
        Logger logger = C0200k.f2997n;
        if (iA > 4096) {
            iA = 4096;
        }
        C0200k c0200k = new C0200k(o0Var, iA);
        fVar.b(c0200k);
        if (c0200k.f3002l > 0) {
            c0200k.y0();
        }
    }
}
