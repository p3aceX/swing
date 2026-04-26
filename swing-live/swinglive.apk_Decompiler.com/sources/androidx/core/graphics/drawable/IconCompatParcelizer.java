package androidx.core.graphics.drawable;

import K.k;
import android.content.res.ColorStateList;
import android.graphics.PorterDuff;
import android.os.Parcel;
import android.os.Parcelable;
import d0.AbstractC0322a;
import d0.C0323b;
import java.nio.charset.Charset;

/* JADX INFO: loaded from: classes.dex */
public class IconCompatParcelizer {
    /* JADX WARN: Can't fix incorrect switch cases order, some code will duplicate */
    public static IconCompat read(AbstractC0322a abstractC0322a) {
        IconCompat iconCompat = new IconCompat();
        int i4 = iconCompat.f2858a;
        if (abstractC0322a.e(1)) {
            i4 = ((C0323b) abstractC0322a).e.readInt();
        }
        iconCompat.f2858a = i4;
        byte[] bArr = iconCompat.f2860c;
        if (abstractC0322a.e(2)) {
            Parcel parcel = ((C0323b) abstractC0322a).e;
            int i5 = parcel.readInt();
            if (i5 < 0) {
                bArr = null;
            } else {
                byte[] bArr2 = new byte[i5];
                parcel.readByteArray(bArr2);
                bArr = bArr2;
            }
        }
        iconCompat.f2860c = bArr;
        iconCompat.f2861d = abstractC0322a.f(iconCompat.f2861d, 3);
        int i6 = iconCompat.e;
        if (abstractC0322a.e(4)) {
            i6 = ((C0323b) abstractC0322a).e.readInt();
        }
        iconCompat.e = i6;
        int i7 = iconCompat.f2862f;
        if (abstractC0322a.e(5)) {
            i7 = ((C0323b) abstractC0322a).e.readInt();
        }
        iconCompat.f2862f = i7;
        iconCompat.f2863g = (ColorStateList) abstractC0322a.f(iconCompat.f2863g, 6);
        String string = iconCompat.f2865i;
        if (abstractC0322a.e(7)) {
            string = ((C0323b) abstractC0322a).e.readString();
        }
        iconCompat.f2865i = string;
        String string2 = iconCompat.f2866j;
        if (abstractC0322a.e(8)) {
            string2 = ((C0323b) abstractC0322a).e.readString();
        }
        iconCompat.f2866j = string2;
        iconCompat.f2864h = PorterDuff.Mode.valueOf(iconCompat.f2865i);
        switch (iconCompat.f2858a) {
            case -1:
                Parcelable parcelable = iconCompat.f2861d;
                if (parcelable == null) {
                    throw new IllegalArgumentException("Invalid icon");
                }
                iconCompat.f2859b = parcelable;
                return iconCompat;
            case 0:
            default:
                return iconCompat;
            case 1:
            case 5:
                Parcelable parcelable2 = iconCompat.f2861d;
                if (parcelable2 != null) {
                    iconCompat.f2859b = parcelable2;
                    return iconCompat;
                }
                byte[] bArr3 = iconCompat.f2860c;
                iconCompat.f2859b = bArr3;
                iconCompat.f2858a = 3;
                iconCompat.e = 0;
                iconCompat.f2862f = bArr3.length;
                return iconCompat;
            case 2:
            case 4:
            case k.STRING_SET_FIELD_NUMBER /* 6 */:
                String str = new String(iconCompat.f2860c, Charset.forName("UTF-16"));
                iconCompat.f2859b = str;
                if (iconCompat.f2858a == 2 && iconCompat.f2866j == null) {
                    iconCompat.f2866j = str.split(":", -1)[0];
                }
                return iconCompat;
            case 3:
                iconCompat.f2859b = iconCompat.f2860c;
                return iconCompat;
        }
    }

    public static void write(IconCompat iconCompat, AbstractC0322a abstractC0322a) {
        abstractC0322a.getClass();
        iconCompat.f2865i = iconCompat.f2864h.name();
        switch (iconCompat.f2858a) {
            case -1:
                iconCompat.f2861d = (Parcelable) iconCompat.f2859b;
                break;
            case 1:
            case 5:
                iconCompat.f2861d = (Parcelable) iconCompat.f2859b;
                break;
            case 2:
                iconCompat.f2860c = ((String) iconCompat.f2859b).getBytes(Charset.forName("UTF-16"));
                break;
            case 3:
                iconCompat.f2860c = (byte[]) iconCompat.f2859b;
                break;
            case 4:
            case k.STRING_SET_FIELD_NUMBER /* 6 */:
                iconCompat.f2860c = iconCompat.f2859b.toString().getBytes(Charset.forName("UTF-16"));
                break;
        }
        int i4 = iconCompat.f2858a;
        if (-1 != i4) {
            abstractC0322a.h(1);
            ((C0323b) abstractC0322a).e.writeInt(i4);
        }
        byte[] bArr = iconCompat.f2860c;
        if (bArr != null) {
            abstractC0322a.h(2);
            int length = bArr.length;
            Parcel parcel = ((C0323b) abstractC0322a).e;
            parcel.writeInt(length);
            parcel.writeByteArray(bArr);
        }
        Parcelable parcelable = iconCompat.f2861d;
        if (parcelable != null) {
            abstractC0322a.h(3);
            ((C0323b) abstractC0322a).e.writeParcelable(parcelable, 0);
        }
        int i5 = iconCompat.e;
        if (i5 != 0) {
            abstractC0322a.h(4);
            ((C0323b) abstractC0322a).e.writeInt(i5);
        }
        int i6 = iconCompat.f2862f;
        if (i6 != 0) {
            abstractC0322a.h(5);
            ((C0323b) abstractC0322a).e.writeInt(i6);
        }
        ColorStateList colorStateList = iconCompat.f2863g;
        if (colorStateList != null) {
            abstractC0322a.h(6);
            ((C0323b) abstractC0322a).e.writeParcelable(colorStateList, 0);
        }
        String str = iconCompat.f2865i;
        if (str != null) {
            abstractC0322a.h(7);
            ((C0323b) abstractC0322a).e.writeString(str);
        }
        String str2 = iconCompat.f2866j;
        if (str2 != null) {
            abstractC0322a.h(8);
            ((C0323b) abstractC0322a).e.writeString(str2);
        }
    }
}
