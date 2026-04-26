package E0;

import K.k;
import android.util.Base64;
import com.google.android.gms.common.internal.F;
import java.math.BigDecimal;
import java.math.BigInteger;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

/* JADX INFO: loaded from: classes.dex */
public abstract class b {
    public static final void b(StringBuilder sb, a aVar, Object obj) {
        int i4 = aVar.f279b;
        if (i4 == 11) {
            Class cls = aVar.f284n;
            F.g(cls);
            sb.append(((b) cls.cast(obj)).toString());
        } else {
            if (i4 != 7) {
                sb.append(obj);
                return;
            }
            sb.append("\"");
            sb.append(G0.b.a((String) obj));
            sb.append("\"");
        }
    }

    public static final <O, I> I zaD(a aVar, Object obj) {
        D0.a aVar2 = aVar.f287q;
        return (aVar2 != null && (obj = (I) ((String) aVar2.f133c.get(((Integer) obj).intValue()))) == null && aVar2.f132b.containsKey("gms_unknown")) ? "gms_unknown" : (I) obj;
    }

    /* JADX WARN: Multi-variable type inference failed */
    public final void a(a aVar, Object obj) {
        D0.a aVar2 = aVar.f287q;
        F.g(aVar2);
        HashMap map = aVar2.f132b;
        Integer num = (Integer) map.get((String) obj);
        Integer num2 = num;
        if (num == null) {
            num2 = (Integer) map.get("gms_unknown");
        }
        F.g(num2);
        String str = aVar.f282f;
        int i4 = aVar.f281d;
        switch (i4) {
            case 0:
                setIntegerInternal(aVar, str, num2.intValue());
                return;
            case 1:
                zaf(aVar, str, (BigInteger) num2);
                return;
            case 2:
                setLongInternal(aVar, str, ((Long) num2).longValue());
                return;
            case 3:
            default:
                StringBuilder sb = new StringBuilder(44);
                sb.append("Unsupported type for conversion: ");
                sb.append(i4);
                throw new IllegalStateException(sb.toString());
            case 4:
                zan(aVar, str, ((Double) num2).doubleValue());
                return;
            case 5:
                zab(aVar, str, (BigDecimal) num2);
                return;
            case k.STRING_SET_FIELD_NUMBER /* 6 */:
                setBooleanInternal(aVar, str, ((Boolean) num2).booleanValue());
                return;
            case k.DOUBLE_FIELD_NUMBER /* 7 */:
                setStringInternal(aVar, str, (String) num2);
                return;
            case k.BYTES_FIELD_NUMBER /* 8 */:
            case 9:
                setDecodedBytesInternal(aVar, str, (byte[]) num2);
                return;
        }
    }

    public <T extends b> void addConcreteTypeArrayInternal(a aVar, String str, ArrayList<T> arrayList) {
        throw new UnsupportedOperationException("Concrete type array not supported");
    }

    public <T extends b> void addConcreteTypeInternal(a aVar, String str, T t4) {
        throw new UnsupportedOperationException("Concrete type not supported");
    }

    public abstract Map<String, a> getFieldMappings();

    public Object getFieldValue(a aVar) {
        String str = aVar.f282f;
        if (aVar.f284n == null) {
            return getValueObject(str);
        }
        if (!(getValueObject(str) == null)) {
            throw new IllegalStateException("Concrete field shouldn't be value object: " + aVar.f282f);
        }
        try {
            char upperCase = Character.toUpperCase(str.charAt(0));
            String strSubstring = str.substring(1);
            StringBuilder sb = new StringBuilder(String.valueOf(strSubstring).length() + 4);
            sb.append("get");
            sb.append(upperCase);
            sb.append(strSubstring);
            return getClass().getMethod(sb.toString(), new Class[0]).invoke(this, new Object[0]);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    public abstract Object getValueObject(String str);

    public boolean isFieldSet(a aVar) {
        if (aVar.f281d != 11) {
            return isPrimitiveFieldSet(aVar.f282f);
        }
        if (aVar.e) {
            throw new UnsupportedOperationException("Concrete type arrays not supported");
        }
        throw new UnsupportedOperationException("Concrete types not supported");
    }

    public abstract boolean isPrimitiveFieldSet(String str);

    public void setBooleanInternal(a aVar, String str, boolean z4) {
        throw new UnsupportedOperationException("Boolean not supported");
    }

    public void setDecodedBytesInternal(a aVar, String str, byte[] bArr) {
        throw new UnsupportedOperationException("byte[] not supported");
    }

    public void setIntegerInternal(a aVar, String str, int i4) {
        throw new UnsupportedOperationException("Integer not supported");
    }

    public void setLongInternal(a aVar, String str, long j4) {
        throw new UnsupportedOperationException("Long not supported");
    }

    public void setStringInternal(a aVar, String str, String str2) {
        throw new UnsupportedOperationException("String not supported");
    }

    public void setStringMapInternal(a aVar, String str, Map<String, String> map) {
        throw new UnsupportedOperationException("String map not supported");
    }

    public void setStringsInternal(a aVar, String str, ArrayList<String> arrayList) {
        throw new UnsupportedOperationException("String list not supported");
    }

    public String toString() {
        Map<String, a> fieldMappings = getFieldMappings();
        StringBuilder sb = new StringBuilder(100);
        for (String str : fieldMappings.keySet()) {
            a aVar = fieldMappings.get(str);
            if (isFieldSet(aVar)) {
                Object objZaD = zaD(aVar, getFieldValue(aVar));
                if (sb.length() == 0) {
                    sb.append("{");
                } else {
                    sb.append(",");
                }
                sb.append("\"");
                sb.append(str);
                sb.append("\":");
                if (objZaD != null) {
                    switch (aVar.f281d) {
                        case k.BYTES_FIELD_NUMBER /* 8 */:
                            sb.append("\"");
                            sb.append(Base64.encodeToString((byte[]) objZaD, 0));
                            sb.append("\"");
                            break;
                        case 9:
                            sb.append("\"");
                            sb.append(Base64.encodeToString((byte[]) objZaD, 10));
                            sb.append("\"");
                            break;
                        case 10:
                            G0.a.f(sb, (HashMap) objZaD);
                            break;
                        default:
                            if (aVar.f280c) {
                                ArrayList arrayList = (ArrayList) objZaD;
                                sb.append("[");
                                int size = arrayList.size();
                                for (int i4 = 0; i4 < size; i4++) {
                                    if (i4 > 0) {
                                        sb.append(",");
                                    }
                                    Object obj = arrayList.get(i4);
                                    if (obj != null) {
                                        b(sb, aVar, obj);
                                    }
                                }
                                sb.append("]");
                            } else {
                                b(sb, aVar, objZaD);
                            }
                            break;
                    }
                } else {
                    sb.append("null");
                }
            }
        }
        if (sb.length() > 0) {
            sb.append("}");
        } else {
            sb.append("{}");
        }
        return sb.toString();
    }

    public final <O> void zaA(a aVar, String str) {
        if (aVar.f287q != null) {
            a(aVar, str);
        } else {
            setStringInternal(aVar, aVar.f282f, str);
        }
    }

    public final <O> void zaB(a aVar, Map<String, String> map) {
        if (aVar.f287q != null) {
            a(aVar, map);
        } else {
            setStringMapInternal(aVar, aVar.f282f, map);
        }
    }

    public final <O> void zaC(a aVar, ArrayList<String> arrayList) {
        if (aVar.f287q != null) {
            a(aVar, arrayList);
        } else {
            setStringsInternal(aVar, aVar.f282f, arrayList);
        }
    }

    public final <O> void zaa(a aVar, BigDecimal bigDecimal) {
        if (aVar.f287q != null) {
            a(aVar, bigDecimal);
        } else {
            zab(aVar, aVar.f282f, bigDecimal);
        }
    }

    public void zab(a aVar, String str, BigDecimal bigDecimal) {
        throw new UnsupportedOperationException("BigDecimal not supported");
    }

    public final <O> void zac(a aVar, ArrayList<BigDecimal> arrayList) {
        if (aVar.f287q != null) {
            a(aVar, arrayList);
        } else {
            zad(aVar, aVar.f282f, arrayList);
        }
    }

    public void zad(a aVar, String str, ArrayList<BigDecimal> arrayList) {
        throw new UnsupportedOperationException("BigDecimal list not supported");
    }

    public final <O> void zae(a aVar, BigInteger bigInteger) {
        if (aVar.f287q != null) {
            a(aVar, bigInteger);
        } else {
            zaf(aVar, aVar.f282f, bigInteger);
        }
    }

    public void zaf(a aVar, String str, BigInteger bigInteger) {
        throw new UnsupportedOperationException("BigInteger not supported");
    }

    public final <O> void zag(a aVar, ArrayList<BigInteger> arrayList) {
        if (aVar.f287q != null) {
            a(aVar, arrayList);
        } else {
            zah(aVar, aVar.f282f, arrayList);
        }
    }

    public void zah(a aVar, String str, ArrayList<BigInteger> arrayList) {
        throw new UnsupportedOperationException("BigInteger list not supported");
    }

    public final <O> void zai(a aVar, boolean z4) {
        if (aVar.f287q != null) {
            a(aVar, Boolean.valueOf(z4));
        } else {
            setBooleanInternal(aVar, aVar.f282f, z4);
        }
    }

    public final <O> void zaj(a aVar, ArrayList<Boolean> arrayList) {
        if (aVar.f287q != null) {
            a(aVar, arrayList);
        } else {
            zak(aVar, aVar.f282f, arrayList);
        }
    }

    public void zak(a aVar, String str, ArrayList<Boolean> arrayList) {
        throw new UnsupportedOperationException("Boolean list not supported");
    }

    public final <O> void zal(a aVar, byte[] bArr) {
        if (aVar.f287q != null) {
            a(aVar, bArr);
        } else {
            setDecodedBytesInternal(aVar, aVar.f282f, bArr);
        }
    }

    public final <O> void zam(a aVar, double d5) {
        if (aVar.f287q != null) {
            a(aVar, Double.valueOf(d5));
        } else {
            zan(aVar, aVar.f282f, d5);
        }
    }

    public void zan(a aVar, String str, double d5) {
        throw new UnsupportedOperationException("Double not supported");
    }

    public final <O> void zao(a aVar, ArrayList<Double> arrayList) {
        if (aVar.f287q != null) {
            a(aVar, arrayList);
        } else {
            zap(aVar, aVar.f282f, arrayList);
        }
    }

    public void zap(a aVar, String str, ArrayList<Double> arrayList) {
        throw new UnsupportedOperationException("Double list not supported");
    }

    public final <O> void zaq(a aVar, float f4) {
        if (aVar.f287q != null) {
            a(aVar, Float.valueOf(f4));
        } else {
            zar(aVar, aVar.f282f, f4);
        }
    }

    public void zar(a aVar, String str, float f4) {
        throw new UnsupportedOperationException("Float not supported");
    }

    public final <O> void zas(a aVar, ArrayList<Float> arrayList) {
        if (aVar.f287q != null) {
            a(aVar, arrayList);
        } else {
            zat(aVar, aVar.f282f, arrayList);
        }
    }

    public void zat(a aVar, String str, ArrayList<Float> arrayList) {
        throw new UnsupportedOperationException("Float list not supported");
    }

    public final <O> void zau(a aVar, int i4) {
        if (aVar.f287q != null) {
            a(aVar, Integer.valueOf(i4));
        } else {
            setIntegerInternal(aVar, aVar.f282f, i4);
        }
    }

    public final <O> void zav(a aVar, ArrayList<Integer> arrayList) {
        if (aVar.f287q != null) {
            a(aVar, arrayList);
        } else {
            zaw(aVar, aVar.f282f, arrayList);
        }
    }

    public void zaw(a aVar, String str, ArrayList<Integer> arrayList) {
        throw new UnsupportedOperationException("Integer list not supported");
    }

    public final <O> void zax(a aVar, long j4) {
        if (aVar.f287q != null) {
            a(aVar, Long.valueOf(j4));
        } else {
            setLongInternal(aVar, aVar.f282f, j4);
        }
    }

    public final <O> void zay(a aVar, ArrayList<Long> arrayList) {
        if (aVar.f287q != null) {
            a(aVar, arrayList);
        } else {
            zaz(aVar, aVar.f282f, arrayList);
        }
    }

    public void zaz(a aVar, String str, ArrayList<Long> arrayList) {
        throw new UnsupportedOperationException("Long list not supported");
    }
}
