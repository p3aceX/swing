package y2;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.LinearGradient;
import android.graphics.Paint;
import android.graphics.RectF;
import android.graphics.Shader;
import android.graphics.Typeface;
import java.util.ArrayList;
import java.util.List;
import java.util.ListIterator;
import java.util.Map;
import java.util.RandomAccess;
import x3.AbstractC0728h;
import x3.AbstractC0729i;

/* JADX INFO: renamed from: y2.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0759a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final d f6860a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Bitmap f6861b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public Canvas f6862c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final Paint f6863d;
    public final Paint e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final Paint f6864f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public String f6865g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public long f6866h;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public final long f6867i;

    public C0759a(Context context, d dVar) {
        J3.i.e(context, "context");
        this.f6860a = dVar;
        Paint paint = new Paint(1);
        paint.setStyle(Paint.Style.FILL);
        this.f6863d = paint;
        Paint paint2 = new Paint(1);
        paint2.setStyle(Paint.Style.STROKE);
        paint2.setStrokeWidth(2.0f);
        paint2.setColor(-1);
        this.e = paint2;
        Paint paint3 = new Paint(1);
        paint3.setColor(-1);
        paint3.setTypeface(Typeface.create(Typeface.DEFAULT, 1));
        this.f6864f = paint3;
        this.f6867i = 2000L;
    }

    public final void a(Canvas canvas, Map map, int i4, int i5) {
        String string;
        Object obj;
        String string2;
        Object obj2;
        String string3;
        Number number;
        Object obj3;
        Object obj4;
        Object obj5 = map.get("data");
        Map map2 = obj5 instanceof Map ? (Map) obj5 : null;
        if (map2 == null) {
            map2 = map;
        }
        Object obj6 = map2.get("batting");
        Map map3 = obj6 instanceof Map ? (Map) obj6 : null;
        Object obj7 = map2.get("inningsSummary");
        List list = obj7 instanceof List ? (List) obj7 : null;
        Object objB0 = list != null ? AbstractC0728h.b0(list) : null;
        Map map4 = objB0 instanceof Map ? (Map) objB0 : null;
        if (map3 == null || (obj4 = map3.get("score")) == null || (string = obj4.toString()) == null) {
            string = (map4 == null || (obj = map4.get("score")) == null) ? "0/0" : obj.toString();
        }
        if (map3 == null || (obj3 = map3.get("overs")) == null || (string2 = obj3.toString()) == null) {
            string2 = (map4 == null || (obj2 = map4.get("overs")) == null) ? "0.0" : obj2.toString();
        }
        String str = string + '-' + string2;
        Object obj8 = map2.get("thisOver");
        List list2 = obj8 instanceof List ? (List) obj8 : null;
        if (list2 == null) {
            return;
        }
        Object objB02 = AbstractC0728h.b0(list2);
        Map map5 = objB02 instanceof Map ? (Map) objB02 : null;
        if (map5 == null) {
            return;
        }
        Object obj9 = map5.get("display");
        if (obj9 == null || (string3 = obj9.toString()) == null) {
            string3 = "";
        }
        try {
            Object obj10 = map5.get("runs");
            number = obj10 instanceof Number ? (Number) obj10 : null;
        } catch (Exception unused) {
        }
        int iIntValue = number != null ? number.intValue() : 0;
        Object obj11 = map5.get("isWicket");
        Boolean bool = obj11 instanceof Boolean ? (Boolean) obj11 : null;
        boolean zBooleanValue = bool != null ? bool.booleanValue() : P3.m.q0(string3, "W", true);
        boolean z4 = iIntValue == 4 || iIntValue == 6 || zBooleanValue;
        if (z4 && !J3.i.a(str, this.f6865g)) {
            this.f6865g = str;
            this.f6866h = System.currentTimeMillis();
        }
        if (!z4 || System.currentTimeMillis() - this.f6866h > this.f6867i) {
            return;
        }
        float f4 = i4;
        float f5 = f4 / 1280.0f;
        float f6 = f4 / 2.0f;
        float f7 = (i5 / 2.0f) - 50.0f;
        float f8 = 2;
        float f9 = (400.0f * f5) / f8;
        float f10 = (120.0f * f5) / f8;
        RectF rectF = new RectF(f6 - f9, f7 - f10, f9 + f6, f10 + f7);
        w3.g gVar = zBooleanValue ? new w3.g("WICKET!", "#C0392B", "#E74C3C") : iIntValue == 6 ? new w3.g("SIX!", "#F1C40F", "#F39C12") : new w3.g("FOUR!", "#2980B9", "#3498DB");
        String str2 = gVar.f6725a;
        LinearGradient linearGradient = new LinearGradient(rectF.left, rectF.top, rectF.right, rectF.bottom, Color.parseColor(gVar.f6726b), Color.parseColor(gVar.f6727c), Shader.TileMode.CLAMP);
        Paint paint = this.f6863d;
        paint.setShader(linearGradient);
        float f11 = 20.0f * f5;
        canvas.drawRoundRect(rectF, f11, f11, paint);
        paint.setShader(null);
        Paint paint2 = this.e;
        paint2.setColor(-1);
        paint2.setStrokeWidth(4.0f * f5);
        canvas.drawRoundRect(rectF, f11, f11, paint2);
        Paint paint3 = this.f6864f;
        paint3.setTextAlign(Paint.Align.CENTER);
        paint3.setTextSize(70.0f * f5);
        paint3.setColor(iIntValue == 6 ? -16777216 : -1);
        canvas.drawText(str2, f6, (f5 * 25.0f) + f7, paint3);
    }

    public final void b(Canvas canvas, String str, String str2, int i4, int i5) {
        Paint paint = new Paint();
        paint.setColor(Color.parseColor("#EE000000"));
        float f4 = i4;
        float f5 = i5;
        canvas.drawRect(0.0f, 0.0f, f4, f5, paint);
        Paint paint2 = this.f6864f;
        paint2.setTextAlign(Paint.Align.CENTER);
        float f6 = f4 / 1280.0f;
        paint2.setTextSize(f6 * 60.0f);
        paint2.setColor(-1);
        float f7 = f4 / 2.0f;
        float f8 = f5 / 2.0f;
        canvas.drawText(str, f7, f8 - 40.0f, paint2);
        paint2.setTextSize(f6 * 30.0f);
        paint2.setColor(-3355444);
        canvas.drawText(str2, f7, f8 + 60.0f, paint2);
    }

    public final void c(Canvas canvas, Map map, int i4, int i5) {
        String string;
        Object obj;
        String string2;
        Object obj2;
        String string3;
        Object obj3;
        String string4;
        String str;
        float f4;
        String str2;
        String string5;
        String str3;
        String string6;
        String string7;
        List listI0;
        String strValueOf;
        Object obj4;
        Object obj5;
        String str4;
        String string8;
        String string9;
        String string10;
        String string11;
        String string12;
        Object obj6;
        Object obj7;
        Object obj8;
        String string13;
        Object obj9;
        Object obj10;
        String string14;
        Object obj11;
        String string15;
        Object obj12;
        Object obj13;
        Object obj14;
        float f5 = i4;
        float f6 = f5 / 1280.0f;
        float f7 = f6 * 40.0f;
        float f8 = 80.0f * f6;
        float f9 = (i5 - f8) - f7;
        Object obj15 = map.get("data");
        Map map2 = obj15 instanceof Map ? (Map) obj15 : null;
        Map map3 = map2 == null ? map : map2;
        Paint paint = this.f6863d;
        paint.setColor(Color.parseColor("#1A1A1A"));
        paint.setAlpha(235);
        float f10 = f5 - f7;
        float f11 = f9 + f8;
        float f12 = f6 * 16.0f;
        canvas.drawRoundRect(new RectF(f7, f9, f10, f11), f12, f12, paint);
        Object obj16 = map3.get("batting");
        Map map4 = obj16 instanceof Map ? (Map) obj16 : null;
        Object obj17 = map3.get("inningsSummary");
        List list = obj17 instanceof List ? (List) obj17 : null;
        Object objB0 = list != null ? AbstractC0728h.b0(list) : null;
        Map map5 = objB0 instanceof Map ? (Map) objB0 : null;
        if (map4 == null || (obj14 = map4.get("score")) == null || (string = obj14.toString()) == null) {
            string = (map5 == null || (obj = map5.get("score")) == null) ? "0/0" : obj.toString();
        }
        if (map4 == null || (obj13 = map4.get("overs")) == null || (string2 = obj13.toString()) == null) {
            string2 = (map5 == null || (obj2 = map5.get("overs")) == null) ? "0.0" : obj2.toString();
        }
        String str5 = string2;
        if (map4 == null || (obj12 = map4.get("teamShortName")) == null || (string3 = obj12.toString()) == null) {
            string3 = (map5 == null || (obj3 = map5.get("shortName")) == null) ? "LIVE" : obj3.toString();
        }
        String str6 = string3;
        float f13 = f6 * 340.0f;
        float f14 = f7 + f13;
        Map map6 = map5;
        paint.setShader(new LinearGradient(f7, f9, f14, f9, Color.parseColor("#E62117"), Color.parseColor("#8E130D"), Shader.TileMode.CLAMP));
        canvas.drawRoundRect(new RectF(f7, f9, f14, f11), f12, f12, paint);
        paint.setShader(null);
        Paint paint2 = this.f6864f;
        paint2.setTextAlign(Paint.Align.CENTER);
        paint2.setTextSize(34.0f * f6);
        paint2.setColor(-1);
        float f15 = 2;
        float f16 = (f13 / f15) + f7;
        canvas.drawText(str6 + ' ' + string, f16, (0.48f * f8) + f9, paint2);
        float f17 = 20.0f * f6;
        paint2.setTextSize(f17);
        paint2.setColor(Color.parseColor("#FFD700"));
        Object obj18 = map3.get("target");
        if (obj18 == null || (string4 = obj18.toString()) == null) {
            string4 = "";
        }
        Object obj19 = map6 != null ? map6.get("inningsNumber") : null;
        Number number = obj19 instanceof Number ? (Number) obj19 : null;
        if ((number != null ? number.intValue() : 1) != 2 || string4.length() <= 0) {
            canvas.drawText(B1.a.m("OVERS: ", str5), f16, (f8 * 0.82f) + f9, paint2);
        } else {
            canvas.drawText("TGT: " + string4 + " (" + str5 + " ov)", f16, (f8 * 0.82f) + f9, paint2);
        }
        Object obj20 = map3.get("striker");
        Map map7 = obj20 instanceof Map ? (Map) obj20 : null;
        Object obj21 = map3.get("nonStriker");
        Map map8 = obj21 instanceof Map ? (Map) obj21 : null;
        float f18 = (25.0f * f6) + f14;
        paint2.setTextAlign(Paint.Align.LEFT);
        if (map7 == null || (obj11 = map7.get("name")) == null || (string15 = obj11.toString()) == null || (str = (String) AbstractC0728h.X(P3.m.D0(string15, new String[]{" "}))) == null) {
            str = "Striker";
        }
        if (map7 == null || (obj10 = map7.get("runs")) == null || (string14 = obj10.toString()) == null) {
            f4 = f12;
            str2 = "0";
        } else {
            f4 = f12;
            str2 = string14;
        }
        if (map7 == null || (obj9 = map7.get("balls")) == null || (string5 = obj9.toString()) == null) {
            string5 = "0";
        }
        paint2.setTextSize(f6 * 26.0f);
        paint2.setColor(-1);
        canvas.drawText(str + "* " + str2 + '(' + string5 + ')', f18, (0.45f * f8) + f9, paint2);
        if (map8 == null || (obj8 = map8.get("name")) == null || (string13 = obj8.toString()) == null || (str3 = (String) AbstractC0728h.X(P3.m.D0(string13, new String[]{" "}))) == null) {
            str3 = "Non-Striker";
        }
        if (map8 == null || (obj7 = map8.get("runs")) == null || (string6 = obj7.toString()) == null) {
            string6 = "0";
        }
        if (map8 == null || (obj6 = map8.get("balls")) == null || (string7 = obj6.toString()) == null) {
            string7 = "0";
        }
        paint2.setTextSize(22.0f * f6);
        paint2.setColor(Color.parseColor("#BBBBBB"));
        canvas.drawText(str3 + ' ' + string6 + '(' + string7 + ')', f18, (0.78f * f8) + f9, paint2);
        Object obj22 = map3.get("bowler");
        Map map9 = obj22 instanceof Map ? (Map) obj22 : null;
        float f19 = f10 - f17;
        paint2.setTextAlign(Paint.Align.RIGHT);
        if (map9 != null) {
            Object obj23 = map9.get("name");
            if (obj23 == null || (string12 = obj23.toString()) == null || (str4 = (String) AbstractC0728h.X(P3.m.D0(string12, new String[]{" "}))) == null) {
                str4 = "Bowler";
            }
            Object obj24 = map9.get("overs");
            if (obj24 == null || (string8 = obj24.toString()) == null) {
                string8 = "0";
            }
            Object obj25 = map9.get("maidens");
            if (obj25 == null || (string9 = obj25.toString()) == null) {
                string9 = "0";
            }
            Object obj26 = map9.get("runs");
            if (obj26 == null || (string10 = obj26.toString()) == null) {
                string10 = "0";
            }
            Object obj27 = map9.get("wickets");
            if (obj27 == null || (string11 = obj27.toString()) == null) {
                string11 = "0";
            }
            paint2.setTextSize(24.0f * f6);
            paint2.setColor(-1);
            canvas.drawText(str4 + ' ' + string8 + '-' + string9 + '-' + string10 + '-' + string11, f19, (0.38f * f8) + f9, paint2);
        }
        Object obj28 = map3.get("thisOver");
        List list2 = obj28 instanceof List ? (List) obj28 : null;
        if (list2 != null) {
            float f20 = 8.0f * f6;
            float f21 = (0.72f * f8) + f9;
            int size = list2.size();
            if (6 >= size) {
                listI0 = AbstractC0728h.i0(list2);
            } else {
                ArrayList arrayList = new ArrayList(6);
                if (list2 instanceof RandomAccess) {
                    for (int i6 = size - 6; i6 < size; i6++) {
                        arrayList.add(list2.get(i6));
                    }
                } else {
                    ListIterator listIterator = list2.listIterator(size - 6);
                    while (listIterator.hasNext()) {
                        arrayList.add(listIterator.next());
                    }
                }
                listI0 = arrayList;
            }
            int i7 = 0;
            for (Object obj29 : listI0) {
                int i8 = i7 + 1;
                if (i7 < 0) {
                    AbstractC0729i.U();
                    throw null;
                }
                Map map10 = obj29 instanceof Map ? (Map) obj29 : null;
                if (map10 == null || (obj5 = map10.get("display")) == null || (strValueOf = obj5.toString()) == null) {
                    strValueOf = String.valueOf(obj29);
                }
                Object obj30 = map10 != null ? map10.get("isWicket") : null;
                Boolean bool = obj30 instanceof Boolean ? (Boolean) obj30 : null;
                boolean zBooleanValue = bool != null ? bool.booleanValue() : P3.m.q0(strValueOf, "W", true);
                if (map10 != null) {
                    try {
                        obj4 = map10.get("runs");
                    } catch (Exception unused) {
                    }
                } else {
                    obj4 = null;
                }
                Number number2 = obj4 instanceof Number ? (Number) obj4 : null;
                int iIntValue = number2 != null ? number2.intValue() : 0;
                float size2 = (f19 - (((f4 * f15) + f20) * ((listI0.size() - 1) - i7))) - f4;
                paint.setColor(zBooleanValue ? Color.parseColor("#C0392B") : iIntValue == 4 ? Color.parseColor("#2980B9") : iIntValue == 6 ? Color.parseColor("#F1C40F") : Color.parseColor("#444444"));
                float f22 = i7 == listI0.size() + (-1) ? 1.25f * f4 : f4;
                canvas.drawCircle(size2, f21, f22, paint);
                List list3 = listI0;
                if (i7 == listI0.size() - 1) {
                    Paint paint3 = this.e;
                    float f23 = 2.0f * f6;
                    paint3.setStrokeWidth(f23);
                    canvas.drawCircle(size2, f21, f23 + f22, paint3);
                }
                paint2.setTextAlign(Paint.Align.CENTER);
                paint2.setTextSize((f22 > f4 ? 16.0f : 14.0f) * f6);
                paint2.setColor(iIntValue == 6 ? -16777216 : -1);
                canvas.drawText(strValueOf, size2, (6.0f * f6) + f21, paint2);
                listI0 = list3;
                i7 = i8;
            }
        }
    }

    /* JADX WARN: Removed duplicated region for block: B:14:0x002a  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final void d(java.util.Map r10, int r11, int r12, java.lang.String r13, int r14) {
        /*
            Method dump skipped, instruction units count: 260
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: y2.C0759a.d(java.util.Map, int, int, java.lang.String, int):void");
    }
}
