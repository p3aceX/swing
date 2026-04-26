package E0;

import K.k;
import a.AbstractC0184a;
import android.os.Bundle;
import android.os.Parcel;
import android.os.Parcelable;
import android.util.Base64;
import android.util.SparseArray;
import com.google.android.gms.common.internal.F;
import com.google.android.gms.dynamite.descriptors.com.google.firebase.auth.ModuleDescriptor;
import java.math.BigDecimal;
import java.math.BigInteger;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;

/* JADX INFO: loaded from: classes.dex */
public final class d extends c {
    public static final Parcelable.Creator<d> CREATOR = new D0.c(6);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f288a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final Parcel f289b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final int f290c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final h f291d;
    public final String e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public int f292f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public int f293m;

    public d(int i4, Parcel parcel, h hVar) {
        this.f288a = i4;
        F.g(parcel);
        this.f289b = parcel;
        this.f290c = 2;
        this.f291d = hVar;
        this.e = hVar == null ? null : hVar.f302c;
        this.f292f = 2;
    }

    public static void e(StringBuilder sb, Map map, Parcel parcel) {
        BigInteger bigInteger;
        Parcel parcelObtain;
        BigInteger[] bigIntegerArr;
        long[] jArrCreateLongArray;
        float[] fArrCreateFloatArray;
        double[] dArrCreateDoubleArray;
        BigDecimal[] bigDecimalArr;
        boolean[] zArrCreateBooleanArray;
        String[] strArrCreateStringArray;
        Parcel[] parcelArr;
        BigInteger bigInteger2;
        SparseArray sparseArray = new SparseArray();
        for (Map.Entry entry : map.entrySet()) {
            sparseArray.put(((a) entry.getValue()).f283m, entry);
        }
        sb.append('{');
        int iI0 = H0.a.i0(parcel);
        boolean z4 = false;
        while (parcel.dataPosition() < iI0) {
            int i4 = parcel.readInt();
            Map.Entry entry2 = (Map.Entry) sparseArray.get((char) i4);
            if (entry2 != null) {
                if (z4) {
                    sb.append(",");
                }
                String str = (String) entry2.getKey();
                a aVar = (a) entry2.getValue();
                sb.append("\"");
                sb.append(str);
                sb.append("\":");
                D0.a aVar2 = aVar.f287q;
                int i5 = aVar.f281d;
                if (aVar2 != null) {
                    switch (i5) {
                        case 0:
                            g(sb, aVar, b.zaD(aVar, Integer.valueOf(H0.a.U(i4, parcel))));
                            break;
                        case 1:
                            int iY = H0.a.Y(i4, parcel);
                            int iDataPosition = parcel.dataPosition();
                            if (iY == 0) {
                                bigInteger2 = null;
                            } else {
                                byte[] bArrCreateByteArray = parcel.createByteArray();
                                parcel.setDataPosition(iDataPosition + iY);
                                bigInteger2 = new BigInteger(bArrCreateByteArray);
                            }
                            g(sb, aVar, b.zaD(aVar, bigInteger2));
                            break;
                        case 2:
                            g(sb, aVar, b.zaD(aVar, Long.valueOf(H0.a.W(i4, parcel))));
                            break;
                        case 3:
                            H0.a.n0(parcel, i4, 4);
                            g(sb, aVar, b.zaD(aVar, Float.valueOf(parcel.readFloat())));
                            break;
                        case 4:
                            H0.a.n0(parcel, i4, 8);
                            g(sb, aVar, b.zaD(aVar, Double.valueOf(parcel.readDouble())));
                            break;
                        case 5:
                            g(sb, aVar, b.zaD(aVar, H0.a.h(i4, parcel)));
                            break;
                        case k.STRING_SET_FIELD_NUMBER /* 6 */:
                            g(sb, aVar, b.zaD(aVar, Boolean.valueOf(H0.a.S(i4, parcel))));
                            break;
                        case k.DOUBLE_FIELD_NUMBER /* 7 */:
                            g(sb, aVar, b.zaD(aVar, H0.a.q(i4, parcel)));
                            break;
                        case k.BYTES_FIELD_NUMBER /* 8 */:
                        case 9:
                            g(sb, aVar, b.zaD(aVar, H0.a.j(i4, parcel)));
                            break;
                        case 10:
                            Bundle bundleI = H0.a.i(i4, parcel);
                            HashMap map2 = new HashMap();
                            for (String str2 : bundleI.keySet()) {
                                String string = bundleI.getString(str2);
                                F.g(string);
                                map2.put(str2, string);
                            }
                            g(sb, aVar, b.zaD(aVar, map2));
                            break;
                        case ModuleDescriptor.MODULE_VERSION /* 11 */:
                            throw new IllegalArgumentException("Method does not accept concrete type.");
                        default:
                            StringBuilder sb2 = new StringBuilder(36);
                            sb2.append("Unknown field out type = ");
                            sb2.append(i5);
                            throw new IllegalArgumentException(sb2.toString());
                    }
                } else {
                    boolean z5 = aVar.e;
                    String str3 = aVar.f285o;
                    if (z5) {
                        sb.append("[");
                        switch (i5) {
                            case 0:
                                int[] iArrM = H0.a.m(i4, parcel);
                                int length = iArrM.length;
                                for (int i6 = 0; i6 < length; i6++) {
                                    if (i6 != 0) {
                                        sb.append(",");
                                    }
                                    sb.append(Integer.toString(iArrM[i6]));
                                }
                                break;
                            case 1:
                                int iY2 = H0.a.Y(i4, parcel);
                                int iDataPosition2 = parcel.dataPosition();
                                if (iY2 == 0) {
                                    bigIntegerArr = null;
                                } else {
                                    int i7 = parcel.readInt();
                                    bigIntegerArr = new BigInteger[i7];
                                    for (int i8 = 0; i8 < i7; i8++) {
                                        bigIntegerArr[i8] = new BigInteger(parcel.createByteArray());
                                    }
                                    parcel.setDataPosition(iDataPosition2 + iY2);
                                }
                                int length2 = bigIntegerArr.length;
                                for (int i9 = 0; i9 < length2; i9++) {
                                    if (i9 != 0) {
                                        sb.append(",");
                                    }
                                    sb.append(bigIntegerArr[i9]);
                                }
                                break;
                            case 2:
                                int iY3 = H0.a.Y(i4, parcel);
                                int iDataPosition3 = parcel.dataPosition();
                                if (iY3 == 0) {
                                    jArrCreateLongArray = null;
                                } else {
                                    jArrCreateLongArray = parcel.createLongArray();
                                    parcel.setDataPosition(iDataPosition3 + iY3);
                                }
                                int length3 = jArrCreateLongArray.length;
                                for (int i10 = 0; i10 < length3; i10++) {
                                    if (i10 != 0) {
                                        sb.append(",");
                                    }
                                    sb.append(Long.toString(jArrCreateLongArray[i10]));
                                }
                                break;
                            case 3:
                                int iY4 = H0.a.Y(i4, parcel);
                                int iDataPosition4 = parcel.dataPosition();
                                if (iY4 == 0) {
                                    fArrCreateFloatArray = null;
                                } else {
                                    fArrCreateFloatArray = parcel.createFloatArray();
                                    parcel.setDataPosition(iDataPosition4 + iY4);
                                }
                                int length4 = fArrCreateFloatArray.length;
                                for (int i11 = 0; i11 < length4; i11++) {
                                    if (i11 != 0) {
                                        sb.append(",");
                                    }
                                    sb.append(Float.toString(fArrCreateFloatArray[i11]));
                                }
                                break;
                            case 4:
                                int iY5 = H0.a.Y(i4, parcel);
                                int iDataPosition5 = parcel.dataPosition();
                                if (iY5 == 0) {
                                    dArrCreateDoubleArray = null;
                                } else {
                                    dArrCreateDoubleArray = parcel.createDoubleArray();
                                    parcel.setDataPosition(iDataPosition5 + iY5);
                                }
                                int length5 = dArrCreateDoubleArray.length;
                                for (int i12 = 0; i12 < length5; i12++) {
                                    if (i12 != 0) {
                                        sb.append(",");
                                    }
                                    sb.append(Double.toString(dArrCreateDoubleArray[i12]));
                                }
                                break;
                            case 5:
                                int iY6 = H0.a.Y(i4, parcel);
                                int iDataPosition6 = parcel.dataPosition();
                                if (iY6 == 0) {
                                    bigDecimalArr = null;
                                } else {
                                    int i13 = parcel.readInt();
                                    bigDecimalArr = new BigDecimal[i13];
                                    for (int i14 = 0; i14 < i13; i14++) {
                                        bigDecimalArr[i14] = new BigDecimal(new BigInteger(parcel.createByteArray()), parcel.readInt());
                                    }
                                    parcel.setDataPosition(iDataPosition6 + iY6);
                                }
                                int length6 = bigDecimalArr.length;
                                for (int i15 = 0; i15 < length6; i15++) {
                                    if (i15 != 0) {
                                        sb.append(",");
                                    }
                                    sb.append(bigDecimalArr[i15]);
                                }
                                break;
                            case k.STRING_SET_FIELD_NUMBER /* 6 */:
                                int iY7 = H0.a.Y(i4, parcel);
                                int iDataPosition7 = parcel.dataPosition();
                                if (iY7 == 0) {
                                    zArrCreateBooleanArray = null;
                                } else {
                                    zArrCreateBooleanArray = parcel.createBooleanArray();
                                    parcel.setDataPosition(iDataPosition7 + iY7);
                                }
                                int length7 = zArrCreateBooleanArray.length;
                                for (int i16 = 0; i16 < length7; i16++) {
                                    if (i16 != 0) {
                                        sb.append(",");
                                    }
                                    sb.append(Boolean.toString(zArrCreateBooleanArray[i16]));
                                }
                                break;
                            case k.DOUBLE_FIELD_NUMBER /* 7 */:
                                int iY8 = H0.a.Y(i4, parcel);
                                int iDataPosition8 = parcel.dataPosition();
                                if (iY8 == 0) {
                                    strArrCreateStringArray = null;
                                } else {
                                    strArrCreateStringArray = parcel.createStringArray();
                                    parcel.setDataPosition(iDataPosition8 + iY8);
                                }
                                int length8 = strArrCreateStringArray.length;
                                for (int i17 = 0; i17 < length8; i17++) {
                                    if (i17 != 0) {
                                        sb.append(",");
                                    }
                                    sb.append("\"");
                                    sb.append(strArrCreateStringArray[i17]);
                                    sb.append("\"");
                                }
                                break;
                            case k.BYTES_FIELD_NUMBER /* 8 */:
                            case 9:
                            case 10:
                                throw new UnsupportedOperationException("List of type BASE64, BASE64_URL_SAFE, or STRING_MAP is not supported");
                            case ModuleDescriptor.MODULE_VERSION /* 11 */:
                                int iY9 = H0.a.Y(i4, parcel);
                                int iDataPosition9 = parcel.dataPosition();
                                if (iY9 == 0) {
                                    parcelArr = null;
                                } else {
                                    int i18 = parcel.readInt();
                                    Parcel[] parcelArr2 = new Parcel[i18];
                                    for (int i19 = 0; i19 < i18; i19++) {
                                        int i20 = parcel.readInt();
                                        if (i20 != 0) {
                                            int iDataPosition10 = parcel.dataPosition();
                                            Parcel parcelObtain2 = Parcel.obtain();
                                            parcelObtain2.appendFrom(parcel, iDataPosition10, i20);
                                            parcelArr2[i19] = parcelObtain2;
                                            parcel.setDataPosition(iDataPosition10 + i20);
                                        } else {
                                            parcelArr2[i19] = null;
                                        }
                                    }
                                    parcel.setDataPosition(iDataPosition9 + iY9);
                                    parcelArr = parcelArr2;
                                }
                                int length9 = parcelArr.length;
                                for (int i21 = 0; i21 < length9; i21++) {
                                    if (i21 > 0) {
                                        sb.append(",");
                                    }
                                    parcelArr[i21].setDataPosition(0);
                                    F.g(str3);
                                    F.g(aVar.f286p);
                                    Map map3 = (Map) aVar.f286p.f301b.get(str3);
                                    F.g(map3);
                                    e(sb, map3, parcelArr[i21]);
                                }
                                break;
                            default:
                                throw new IllegalStateException("Unknown field type out.");
                        }
                        sb.append("]");
                    } else {
                        switch (i5) {
                            case 0:
                                sb.append(H0.a.U(i4, parcel));
                                break;
                            case 1:
                                int iY10 = H0.a.Y(i4, parcel);
                                int iDataPosition11 = parcel.dataPosition();
                                if (iY10 == 0) {
                                    bigInteger = null;
                                } else {
                                    byte[] bArrCreateByteArray2 = parcel.createByteArray();
                                    parcel.setDataPosition(iDataPosition11 + iY10);
                                    bigInteger = new BigInteger(bArrCreateByteArray2);
                                }
                                sb.append(bigInteger);
                                break;
                            case 2:
                                sb.append(H0.a.W(i4, parcel));
                                break;
                            case 3:
                                H0.a.n0(parcel, i4, 4);
                                sb.append(parcel.readFloat());
                                break;
                            case 4:
                                H0.a.n0(parcel, i4, 8);
                                sb.append(parcel.readDouble());
                                break;
                            case 5:
                                sb.append(H0.a.h(i4, parcel));
                                break;
                            case k.STRING_SET_FIELD_NUMBER /* 6 */:
                                sb.append(H0.a.S(i4, parcel));
                                break;
                            case k.DOUBLE_FIELD_NUMBER /* 7 */:
                                String strQ = H0.a.q(i4, parcel);
                                sb.append("\"");
                                sb.append(G0.b.a(strQ));
                                sb.append("\"");
                                break;
                            case k.BYTES_FIELD_NUMBER /* 8 */:
                                byte[] bArrJ = H0.a.j(i4, parcel);
                                sb.append("\"");
                                sb.append(bArrJ == null ? null : Base64.encodeToString(bArrJ, 0));
                                sb.append("\"");
                                break;
                            case 9:
                                byte[] bArrJ2 = H0.a.j(i4, parcel);
                                sb.append("\"");
                                sb.append(bArrJ2 == null ? null : Base64.encodeToString(bArrJ2, 10));
                                sb.append("\"");
                                break;
                            case 10:
                                Bundle bundleI2 = H0.a.i(i4, parcel);
                                Set<String> setKeySet = bundleI2.keySet();
                                sb.append("{");
                                boolean z6 = true;
                                for (String str4 : setKeySet) {
                                    if (!z6) {
                                        sb.append(",");
                                    }
                                    sb.append("\"");
                                    sb.append(str4);
                                    sb.append("\":\"");
                                    sb.append(G0.b.a(bundleI2.getString(str4)));
                                    sb.append("\"");
                                    z6 = false;
                                }
                                sb.append("}");
                                break;
                            case ModuleDescriptor.MODULE_VERSION /* 11 */:
                                int iY11 = H0.a.Y(i4, parcel);
                                int iDataPosition12 = parcel.dataPosition();
                                if (iY11 == 0) {
                                    parcelObtain = null;
                                } else {
                                    parcelObtain = Parcel.obtain();
                                    parcelObtain.appendFrom(parcel, iDataPosition12, iY11);
                                    parcel.setDataPosition(iDataPosition12 + iY11);
                                }
                                parcelObtain.setDataPosition(0);
                                F.g(str3);
                                F.g(aVar.f286p);
                                Map map4 = (Map) aVar.f286p.f301b.get(str3);
                                F.g(map4);
                                e(sb, map4, parcelObtain);
                                break;
                            default:
                                throw new IllegalStateException("Unknown field type out");
                        }
                    }
                }
                z4 = true;
            }
        }
        if (parcel.dataPosition() == iI0) {
            sb.append('}');
            return;
        }
        StringBuilder sb3 = new StringBuilder(37);
        sb3.append("Overread allowed size end=");
        sb3.append(iI0);
        throw new A0.b(sb3.toString(), parcel);
    }

    public static final void f(StringBuilder sb, int i4, Object obj) {
        switch (i4) {
            case 0:
            case 1:
            case 2:
            case 3:
            case 4:
            case 5:
            case k.STRING_SET_FIELD_NUMBER /* 6 */:
                sb.append(obj);
                return;
            case k.DOUBLE_FIELD_NUMBER /* 7 */:
                sb.append("\"");
                F.g(obj);
                sb.append(G0.b.a(obj.toString()));
                sb.append("\"");
                return;
            case k.BYTES_FIELD_NUMBER /* 8 */:
                sb.append("\"");
                byte[] bArr = (byte[]) obj;
                sb.append(bArr != null ? Base64.encodeToString(bArr, 0) : null);
                sb.append("\"");
                return;
            case 9:
                sb.append("\"");
                byte[] bArr2 = (byte[]) obj;
                sb.append(bArr2 != null ? Base64.encodeToString(bArr2, 10) : null);
                sb.append("\"");
                return;
            case 10:
                F.g(obj);
                G0.a.f(sb, (HashMap) obj);
                return;
            case ModuleDescriptor.MODULE_VERSION /* 11 */:
                throw new IllegalArgumentException("Method does not accept concrete type.");
            default:
                StringBuilder sb2 = new StringBuilder(26);
                sb2.append("Unknown type = ");
                sb2.append(i4);
                throw new IllegalArgumentException(sb2.toString());
        }
    }

    public static final void g(StringBuilder sb, a aVar, Object obj) {
        boolean z4 = aVar.f280c;
        int i4 = aVar.f279b;
        if (!z4) {
            f(sb, i4, obj);
            return;
        }
        ArrayList arrayList = (ArrayList) obj;
        sb.append("[");
        int size = arrayList.size();
        for (int i5 = 0; i5 < size; i5++) {
            if (i5 != 0) {
                sb.append(",");
            }
            f(sb, i4, arrayList.get(i5));
        }
        sb.append("]");
    }

    @Override // E0.b
    public final void addConcreteTypeArrayInternal(a aVar, String str, ArrayList arrayList) {
        d(aVar);
        ArrayList arrayList2 = new ArrayList();
        F.g(arrayList);
        arrayList.size();
        int size = arrayList.size();
        for (int i4 = 0; i4 < size; i4++) {
            arrayList2.add(((d) ((b) arrayList.get(i4))).c());
        }
        int i5 = aVar.f283m;
        Parcel parcel = this.f289b;
        int iM0 = AbstractC0184a.m0(i5, parcel);
        int size2 = arrayList2.size();
        parcel.writeInt(size2);
        for (int i6 = 0; i6 < size2; i6++) {
            Parcel parcel2 = (Parcel) arrayList2.get(i6);
            if (parcel2 != null) {
                parcel.writeInt(parcel2.dataSize());
                parcel.appendFrom(parcel2, 0, parcel2.dataSize());
            } else {
                parcel.writeInt(0);
            }
        }
        AbstractC0184a.n0(iM0, parcel);
    }

    @Override // E0.b
    public final void addConcreteTypeInternal(a aVar, String str, b bVar) {
        d(aVar);
        Parcel parcelC = ((d) bVar).c();
        Parcel parcel = this.f289b;
        int i4 = aVar.f283m;
        if (parcelC == null) {
            AbstractC0184a.o0(parcel, i4, 0);
            return;
        }
        int iM0 = AbstractC0184a.m0(i4, parcel);
        parcel.appendFrom(parcelC, 0, parcelC.dataSize());
        AbstractC0184a.n0(iM0, parcel);
    }

    public final Parcel c() {
        int i4 = this.f292f;
        Parcel parcel = this.f289b;
        if (i4 != 0) {
            if (i4 != 1) {
                return parcel;
            }
            AbstractC0184a.n0(this.f293m, parcel);
            this.f292f = 2;
            return parcel;
        }
        int iM0 = AbstractC0184a.m0(20293, parcel);
        this.f293m = iM0;
        AbstractC0184a.n0(iM0, parcel);
        this.f292f = 2;
        return parcel;
    }

    public final void d(a aVar) {
        if (aVar.f283m == -1) {
            throw new IllegalStateException("Field does not have a valid safe parcelable field id.");
        }
        Parcel parcel = this.f289b;
        if (parcel == null) {
            throw new IllegalStateException("Internal Parcel object is null.");
        }
        int i4 = this.f292f;
        if (i4 != 0) {
            if (i4 != 1) {
                throw new IllegalStateException("Attempted to parse JSON with a SafeParcelResponse object that is already filled with data.");
            }
        } else {
            this.f293m = AbstractC0184a.m0(20293, parcel);
            this.f292f = 1;
        }
    }

    @Override // E0.b
    public final Map getFieldMappings() {
        h hVar = this.f291d;
        if (hVar == null) {
            return null;
        }
        String str = this.e;
        F.g(str);
        return (Map) hVar.f301b.get(str);
    }

    @Override // E0.c, E0.b
    public final Object getValueObject(String str) {
        throw new UnsupportedOperationException("Converting to JSON does not require this method.");
    }

    @Override // E0.c, E0.b
    public final boolean isPrimitiveFieldSet(String str) {
        throw new UnsupportedOperationException("Converting to JSON does not require this method.");
    }

    @Override // E0.b
    public final void setBooleanInternal(a aVar, String str, boolean z4) {
        d(aVar);
        Parcel parcel = this.f289b;
        AbstractC0184a.o0(parcel, aVar.f283m, 4);
        parcel.writeInt(z4 ? 1 : 0);
    }

    @Override // E0.b
    public final void setDecodedBytesInternal(a aVar, String str, byte[] bArr) {
        d(aVar);
        AbstractC0184a.c0(this.f289b, aVar.f283m, bArr, true);
    }

    @Override // E0.b
    public final void setIntegerInternal(a aVar, String str, int i4) {
        d(aVar);
        Parcel parcel = this.f289b;
        AbstractC0184a.o0(parcel, aVar.f283m, 4);
        parcel.writeInt(i4);
    }

    @Override // E0.b
    public final void setLongInternal(a aVar, String str, long j4) {
        d(aVar);
        Parcel parcel = this.f289b;
        AbstractC0184a.o0(parcel, aVar.f283m, 8);
        parcel.writeLong(j4);
    }

    @Override // E0.b
    public final void setStringInternal(a aVar, String str, String str2) {
        d(aVar);
        AbstractC0184a.i0(this.f289b, aVar.f283m, str2, true);
    }

    @Override // E0.b
    public final void setStringMapInternal(a aVar, String str, Map map) {
        d(aVar);
        Bundle bundle = new Bundle();
        F.g(map);
        for (String str2 : map.keySet()) {
            bundle.putString(str2, (String) map.get(str2));
        }
        AbstractC0184a.b0(this.f289b, aVar.f283m, bundle, true);
    }

    @Override // E0.b
    public final void setStringsInternal(a aVar, String str, ArrayList arrayList) {
        d(aVar);
        F.g(arrayList);
        int size = arrayList.size();
        String[] strArr = new String[size];
        for (int i4 = 0; i4 < size; i4++) {
            strArr[i4] = (String) arrayList.get(i4);
        }
        Parcel parcel = this.f289b;
        int iM0 = AbstractC0184a.m0(aVar.f283m, parcel);
        parcel.writeStringArray(strArr);
        AbstractC0184a.n0(iM0, parcel);
    }

    @Override // E0.b
    public final String toString() {
        h hVar = this.f291d;
        F.h(hVar, "Cannot convert to JSON on client side.");
        Parcel parcelC = c();
        parcelC.setDataPosition(0);
        StringBuilder sb = new StringBuilder(100);
        String str = this.e;
        F.g(str);
        Map map = (Map) hVar.f301b.get(str);
        F.g(map);
        e(sb, map, parcelC);
        return sb.toString();
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.o0(parcel, 1, 4);
        parcel.writeInt(this.f288a);
        Parcel parcelC = c();
        if (parcelC != null) {
            int iM02 = AbstractC0184a.m0(2, parcel);
            parcel.appendFrom(parcelC, 0, parcelC.dataSize());
            AbstractC0184a.n0(iM02, parcel);
        }
        AbstractC0184a.h0(parcel, 3, this.f290c != 0 ? this.f291d : null, i4, false);
        AbstractC0184a.n0(iM0, parcel);
    }

    @Override // E0.b
    public final void zab(a aVar, String str, BigDecimal bigDecimal) {
        d(aVar);
        Parcel parcel = this.f289b;
        int i4 = aVar.f283m;
        if (bigDecimal == null) {
            AbstractC0184a.o0(parcel, i4, 0);
            return;
        }
        int iM0 = AbstractC0184a.m0(i4, parcel);
        parcel.writeByteArray(bigDecimal.unscaledValue().toByteArray());
        parcel.writeInt(bigDecimal.scale());
        AbstractC0184a.n0(iM0, parcel);
    }

    @Override // E0.b
    public final void zad(a aVar, String str, ArrayList arrayList) {
        d(aVar);
        F.g(arrayList);
        int size = arrayList.size();
        BigDecimal[] bigDecimalArr = new BigDecimal[size];
        for (int i4 = 0; i4 < size; i4++) {
            bigDecimalArr[i4] = (BigDecimal) arrayList.get(i4);
        }
        int i5 = aVar.f283m;
        Parcel parcel = this.f289b;
        int iM0 = AbstractC0184a.m0(i5, parcel);
        parcel.writeInt(size);
        for (int i6 = 0; i6 < size; i6++) {
            parcel.writeByteArray(bigDecimalArr[i6].unscaledValue().toByteArray());
            parcel.writeInt(bigDecimalArr[i6].scale());
        }
        AbstractC0184a.n0(iM0, parcel);
    }

    @Override // E0.b
    public final void zaf(a aVar, String str, BigInteger bigInteger) {
        d(aVar);
        Parcel parcel = this.f289b;
        int i4 = aVar.f283m;
        if (bigInteger == null) {
            AbstractC0184a.o0(parcel, i4, 0);
            return;
        }
        int iM0 = AbstractC0184a.m0(i4, parcel);
        parcel.writeByteArray(bigInteger.toByteArray());
        AbstractC0184a.n0(iM0, parcel);
    }

    @Override // E0.b
    public final void zah(a aVar, String str, ArrayList arrayList) {
        d(aVar);
        F.g(arrayList);
        int size = arrayList.size();
        BigInteger[] bigIntegerArr = new BigInteger[size];
        for (int i4 = 0; i4 < size; i4++) {
            bigIntegerArr[i4] = (BigInteger) arrayList.get(i4);
        }
        int i5 = aVar.f283m;
        Parcel parcel = this.f289b;
        int iM0 = AbstractC0184a.m0(i5, parcel);
        parcel.writeInt(size);
        for (int i6 = 0; i6 < size; i6++) {
            parcel.writeByteArray(bigIntegerArr[i6].toByteArray());
        }
        AbstractC0184a.n0(iM0, parcel);
    }

    @Override // E0.b
    public final void zak(a aVar, String str, ArrayList arrayList) {
        d(aVar);
        F.g(arrayList);
        int size = arrayList.size();
        boolean[] zArr = new boolean[size];
        for (int i4 = 0; i4 < size; i4++) {
            zArr[i4] = ((Boolean) arrayList.get(i4)).booleanValue();
        }
        int i5 = aVar.f283m;
        Parcel parcel = this.f289b;
        int iM0 = AbstractC0184a.m0(i5, parcel);
        parcel.writeBooleanArray(zArr);
        AbstractC0184a.n0(iM0, parcel);
    }

    @Override // E0.b
    public final void zan(a aVar, String str, double d5) {
        d(aVar);
        Parcel parcel = this.f289b;
        AbstractC0184a.o0(parcel, aVar.f283m, 8);
        parcel.writeDouble(d5);
    }

    @Override // E0.b
    public final void zap(a aVar, String str, ArrayList arrayList) {
        d(aVar);
        F.g(arrayList);
        int size = arrayList.size();
        double[] dArr = new double[size];
        for (int i4 = 0; i4 < size; i4++) {
            dArr[i4] = ((Double) arrayList.get(i4)).doubleValue();
        }
        int i5 = aVar.f283m;
        Parcel parcel = this.f289b;
        int iM0 = AbstractC0184a.m0(i5, parcel);
        parcel.writeDoubleArray(dArr);
        AbstractC0184a.n0(iM0, parcel);
    }

    @Override // E0.b
    public final void zar(a aVar, String str, float f4) {
        d(aVar);
        Parcel parcel = this.f289b;
        AbstractC0184a.o0(parcel, aVar.f283m, 4);
        parcel.writeFloat(f4);
    }

    @Override // E0.b
    public final void zat(a aVar, String str, ArrayList arrayList) {
        d(aVar);
        F.g(arrayList);
        int size = arrayList.size();
        float[] fArr = new float[size];
        for (int i4 = 0; i4 < size; i4++) {
            fArr[i4] = ((Float) arrayList.get(i4)).floatValue();
        }
        int i5 = aVar.f283m;
        Parcel parcel = this.f289b;
        int iM0 = AbstractC0184a.m0(i5, parcel);
        parcel.writeFloatArray(fArr);
        AbstractC0184a.n0(iM0, parcel);
    }

    @Override // E0.b
    public final void zaw(a aVar, String str, ArrayList arrayList) {
        d(aVar);
        F.g(arrayList);
        int size = arrayList.size();
        int[] iArr = new int[size];
        for (int i4 = 0; i4 < size; i4++) {
            iArr[i4] = ((Integer) arrayList.get(i4)).intValue();
        }
        AbstractC0184a.e0(this.f289b, aVar.f283m, iArr, true);
    }

    @Override // E0.b
    public final void zaz(a aVar, String str, ArrayList arrayList) {
        d(aVar);
        F.g(arrayList);
        int size = arrayList.size();
        long[] jArr = new long[size];
        for (int i4 = 0; i4 < size; i4++) {
            jArr[i4] = ((Long) arrayList.get(i4)).longValue();
        }
        int i5 = aVar.f283m;
        Parcel parcel = this.f289b;
        int iM0 = AbstractC0184a.m0(i5, parcel);
        parcel.writeLongArray(jArr);
        AbstractC0184a.n0(iM0, parcel);
    }
}
