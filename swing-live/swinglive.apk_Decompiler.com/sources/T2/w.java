package T2;

import java.nio.ByteBuffer;
import java.util.ArrayList;

/* JADX INFO: loaded from: classes.dex */
public final class w extends O2.q {

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final w f2004d = new w();

    @Override // O2.q
    public final Object f(byte b5, ByteBuffer byteBuffer) {
        switch (b5) {
            case -127:
                Object objE = e(byteBuffer);
                if (objE == null) {
                    return null;
                }
                return y.values()[((Long) objE).intValue()];
            case -126:
                Object objE2 = e(byteBuffer);
                if (objE2 == null) {
                    return null;
                }
                return A.values()[((Long) objE2).intValue()];
            case -125:
                Object objE3 = e(byteBuffer);
                if (objE3 == null) {
                    return null;
                }
                return B.values()[((Long) objE3).intValue()];
            case -124:
                Object objE4 = e(byteBuffer);
                if (objE4 == null) {
                    return null;
                }
                return D.values()[((Long) objE4).intValue()];
            case -123:
                Object objE5 = e(byteBuffer);
                if (objE5 == null) {
                    return null;
                }
                return H.values()[((Long) objE5).intValue()];
            case -122:
                Object objE6 = e(byteBuffer);
                if (objE6 == null) {
                    return null;
                }
                return E.values()[((Long) objE6).intValue()];
            case -121:
                Object objE7 = e(byteBuffer);
                if (objE7 == null) {
                    return null;
                }
                return C.values()[((Long) objE7).intValue()];
            case -120:
                ArrayList arrayList = (ArrayList) e(byteBuffer);
                x xVar = new x();
                String str = (String) arrayList.get(0);
                if (str == null) {
                    throw new IllegalStateException("Nonnull field \"name\" is null.");
                }
                xVar.f2005a = str;
                y yVar = (y) arrayList.get(1);
                if (yVar == null) {
                    throw new IllegalStateException("Nonnull field \"lensDirection\" is null.");
                }
                xVar.f2006b = yVar;
                Long l2 = (Long) arrayList.get(2);
                if (l2 == null) {
                    throw new IllegalStateException("Nonnull field \"sensorOrientation\" is null.");
                }
                xVar.f2007c = l2;
                return xVar;
            case -119:
                ArrayList arrayList2 = (ArrayList) e(byteBuffer);
                z zVar = new z();
                I i4 = (I) arrayList2.get(0);
                if (i4 == null) {
                    throw new IllegalStateException("Nonnull field \"previewSize\" is null.");
                }
                zVar.f2012a = i4;
                B b6 = (B) arrayList2.get(1);
                if (b6 == null) {
                    throw new IllegalStateException("Nonnull field \"exposureMode\" is null.");
                }
                zVar.f2013b = b6;
                D d5 = (D) arrayList2.get(2);
                if (d5 == null) {
                    throw new IllegalStateException("Nonnull field \"focusMode\" is null.");
                }
                zVar.f2014c = d5;
                Boolean bool = (Boolean) arrayList2.get(3);
                if (bool == null) {
                    throw new IllegalStateException("Nonnull field \"exposurePointSupported\" is null.");
                }
                zVar.f2015d = bool;
                Boolean bool2 = (Boolean) arrayList2.get(4);
                if (bool2 == null) {
                    throw new IllegalStateException("Nonnull field \"focusPointSupported\" is null.");
                }
                zVar.e = bool2;
                return zVar;
            case -118:
                ArrayList arrayList3 = (ArrayList) e(byteBuffer);
                I i5 = new I();
                Double d6 = (Double) arrayList3.get(0);
                if (d6 == null) {
                    throw new IllegalStateException("Nonnull field \"width\" is null.");
                }
                i5.f1902a = d6;
                Double d7 = (Double) arrayList3.get(1);
                if (d7 == null) {
                    throw new IllegalStateException("Nonnull field \"height\" is null.");
                }
                i5.f1903b = d7;
                return i5;
            case -117:
                ArrayList arrayList4 = (ArrayList) e(byteBuffer);
                G g4 = new G();
                Double d8 = (Double) arrayList4.get(0);
                if (d8 == null) {
                    throw new IllegalStateException("Nonnull field \"x\" is null.");
                }
                g4.f1898a = d8;
                Double d9 = (Double) arrayList4.get(1);
                if (d9 == null) {
                    throw new IllegalStateException("Nonnull field \"y\" is null.");
                }
                g4.f1899b = d9;
                return g4;
            case -116:
                ArrayList arrayList5 = (ArrayList) e(byteBuffer);
                F f4 = new F();
                H h4 = (H) arrayList5.get(0);
                if (h4 == null) {
                    throw new IllegalStateException("Nonnull field \"resolutionPreset\" is null.");
                }
                f4.f1894a = h4;
                f4.f1895b = (Long) arrayList5.get(1);
                f4.f1896c = (Long) arrayList5.get(2);
                f4.f1897d = (Long) arrayList5.get(3);
                Boolean bool3 = (Boolean) arrayList5.get(4);
                if (bool3 == null) {
                    throw new IllegalStateException("Nonnull field \"enableAudio\" is null.");
                }
                f4.e = bool3;
                return f4;
            default:
                return super.f(b5, byteBuffer);
        }
    }

    @Override // O2.q
    public final void k(F3.a aVar, Object obj) {
        if (obj instanceof y) {
            aVar.write(129);
            k(aVar, obj != null ? Integer.valueOf(((y) obj).f2011a) : null);
            return;
        }
        if (obj instanceof A) {
            aVar.write(130);
            k(aVar, obj != null ? Integer.valueOf(((A) obj).f1881a) : null);
            return;
        }
        if (obj instanceof B) {
            aVar.write(131);
            k(aVar, obj != null ? Integer.valueOf(((B) obj).f1885a) : null);
            return;
        }
        if (obj instanceof D) {
            aVar.write(132);
            k(aVar, obj != null ? Integer.valueOf(((D) obj).f1891a) : null);
            return;
        }
        if (obj instanceof H) {
            aVar.write(133);
            k(aVar, obj != null ? Integer.valueOf(((H) obj).f1901a) : null);
            return;
        }
        if (obj instanceof E) {
            aVar.write(134);
            k(aVar, obj != null ? Integer.valueOf(((E) obj).f1893a) : null);
            return;
        }
        if (obj instanceof C) {
            aVar.write(135);
            k(aVar, obj != null ? Integer.valueOf(((C) obj).f1887a) : null);
            return;
        }
        if (obj instanceof x) {
            aVar.write(136);
            x xVar = (x) obj;
            xVar.getClass();
            ArrayList arrayList = new ArrayList(3);
            arrayList.add(xVar.f2005a);
            arrayList.add(xVar.f2006b);
            arrayList.add(xVar.f2007c);
            k(aVar, arrayList);
            return;
        }
        if (obj instanceof z) {
            aVar.write(137);
            z zVar = (z) obj;
            zVar.getClass();
            ArrayList arrayList2 = new ArrayList(5);
            arrayList2.add(zVar.f2012a);
            arrayList2.add(zVar.f2013b);
            arrayList2.add(zVar.f2014c);
            arrayList2.add(zVar.f2015d);
            arrayList2.add(zVar.e);
            k(aVar, arrayList2);
            return;
        }
        if (obj instanceof I) {
            aVar.write(138);
            I i4 = (I) obj;
            i4.getClass();
            ArrayList arrayList3 = new ArrayList(2);
            arrayList3.add(i4.f1902a);
            arrayList3.add(i4.f1903b);
            k(aVar, arrayList3);
            return;
        }
        if (obj instanceof G) {
            aVar.write(139);
            G g4 = (G) obj;
            g4.getClass();
            ArrayList arrayList4 = new ArrayList(2);
            arrayList4.add(g4.f1898a);
            arrayList4.add(g4.f1899b);
            k(aVar, arrayList4);
            return;
        }
        if (!(obj instanceof F)) {
            super.k(aVar, obj);
            return;
        }
        aVar.write(140);
        F f4 = (F) obj;
        f4.getClass();
        ArrayList arrayList5 = new ArrayList(5);
        arrayList5.add(f4.f1894a);
        arrayList5.add(f4.f1895b);
        arrayList5.add(f4.f1896c);
        arrayList5.add(f4.f1897d);
        arrayList5.add(f4.e);
        k(aVar, arrayList5);
    }
}
